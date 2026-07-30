--暁光のブイオ
-- 效果：
-- 自己主要怪兽区域左端和右端的怪兽不会被效果破坏。
-- 「夜明之光 布幽」的以下效果1回合各能使用1次。
-- 这张卡在手卡存在的场合：可以以自己场上1只恶魔族效果怪兽为对象；那个效果无效，这张卡特殊召唤。
-- 这张卡被送去墓地的场合：可以从卡组把1张「天国之乱」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤、检索和不被效果破坏
function s.initial_effect(c)
	-- 记录该卡与「天国之乱」的关联
	aux.AddCodeList(c,71593652)
	-- 创建一个起动效果，可以在手牌时发动，对象为己方场上一只恶魔族效果怪兽，使该怪兽效果无效并特殊召唤自己
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建一个诱发效果，当此卡被送去墓地时发动，从卡组检索一张「天国之乱」加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 创建一个永续效果，使自己左右端的怪兽不会被效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选己方场上表侧表示、未被无效且为恶魔族的效果怪兽
function s.cfilter(c)
	-- 返回卡片是否为恶魔族且可被无效
	return c:IsRace(RACE_FIEND) and aux.NegateEffectMonsterFilter(c)
end
-- 特殊召唤效果的目标选择函数，检查是否有满足条件的怪兽可作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 判断是否可以进行特殊召唤操作，包括场地空位和自身能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否存在满足条件的怪兽作为目标
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一个满足条件的怪兽作为目标
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理函数，使目标怪兽效果无效并特殊召唤自己
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 给目标怪兽添加效果无效效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 给目标怪兽添加效果无效化效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if c:IsRelateToChain() then
			-- 将自己特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 检索效果的过滤函数，用于筛选「天国之乱」卡牌
function s.thfilter(c)
	return c:IsCode(71593652) and c:IsAbleToHand()
end
-- 检索效果的目标选择函数，检查卡组中是否存在「天国之乱」
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「天国之乱」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，从卡组选择一张「天国之乱」加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张「天国之乱」加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 不被效果破坏效果的目标筛选函数，判断是否为左右端怪兽
function s.indtg(e,c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
