--アルトメギア・ヴァンダリズム－襲撃－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无垢者 米底乌斯」加入手卡。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，把那只表侧表示怪兽作为融合素材的场合，可以当作「神艺」怪兽使用。
-- ③：自己场上的「神艺学都 神艺学园」被效果破坏的场合，可以作为代替把场上的这张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①检索②对象怪兽效果③代替破坏效果
function s.initial_effect(c)
	-- 记录该卡拥有「无垢者 米底乌斯」和「神艺学都 神艺学园」的卡名
	aux.AddCodeList(c,97556336,74733322)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无垢者 米底乌斯」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，把那只表侧表示怪兽作为融合素材的场合，可以当作「神艺」怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"当作「神艺」怪兽"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	-- ③：自己场上的「神艺学都 神艺学园」被效果破坏的场合，可以作为代替把场上的这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
-- 检索过滤器，用于筛选卡组中「无垢者 米底乌斯」
function s.thfilter(c)
	return c:IsCode(97556336) and c:IsAbleToHand()
end
-- 发动效果处理函数，检索满足条件的「无垢者 米底乌斯」并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「无垢者 米底乌斯」
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡并询问玩家是否发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 对象怪兽过滤器，筛选表侧表示且不是「神艺」怪兽的怪兽
function s.filter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cd)
end
-- 对象选择函数，选择满足条件的表侧表示怪兽
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否存在满足条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的表侧表示怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 对象效果处理函数，使目标怪兽在本回合可当作「神艺」怪兽使用
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「神艺学的破坏-袭击-」效果适用中"
		-- 为对象怪兽添加「神艺」融合素材设定码
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(0x1cd)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 代替破坏过滤器，筛选被效果破坏且为「神艺学都 神艺学园」的卡
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(74733322) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的判定函数，判断是否可以发动代替破坏
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，将该卡送去墓地
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
