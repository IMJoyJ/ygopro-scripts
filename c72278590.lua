--光帰への契り
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「塞尼特」怪兽加入手卡。
-- ②：这张卡在墓地存在的状态，自己把「塞尼特」仪式怪兽从手卡丢弃的场合，把这张卡除外才能发动。把持有丢弃的怪兽的攻击力以下的攻击力的1只效果怪兽以外的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。这个回合，这个效果特殊召唤的怪兽不能直接攻击，自己不能把不死族以外的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册发动时从卡组检索「塞尼特」怪兽、墓地丢弃仪式怪兽时除外自身从额外卡组特召通常融合怪兽的效果
function s.initial_effect(c)
	-- ①：从卡组把1只「塞尼特」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 为单张卡片注册丢弃手牌的合并延迟事件监听
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_DISCARD)
	-- ②：这张卡在墓地存在的状态，自己把「塞尼特」仪式怪兽从手卡丢弃的场合，把这张卡除外才能发动。把持有丢弃的怪兽的攻击力以下的攻击力的1只效果怪兽以外的融合怪兽从额外卡组当作通常怪兽卡使用特殊召唤。这个回合，这个效果特殊召唤的怪兽不能直接攻击，自己不能把不死族以外的怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	-- 效果发动Cost：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可加入手卡的「塞尼特」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1eb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动目标判定：检查卡组是否存在「塞尼特」怪兽并设置检索操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可加入手卡的「塞尼特」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只「塞尼特」怪兽加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「塞尼特」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己从手卡丢弃的「塞尼特」仪式怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x1eb) and c:IsType(TYPE_RITUAL) and c:IsPreviousControler(tp)
end
-- 效果发动条件：自己从手卡把「塞尼特」仪式怪兽丢弃
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤额外卡组中攻击力在丢弃怪兽攻击力以下、非效果怪兽的融合怪兽
function s.spfilter(c,e,tp,sg)
	return c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT)
		-- 检查额外怪兽区域空位以及怪兽是否可以特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and sg:IsExists(Card.IsAttackAbove,1,nil,c:GetTextAttack())
end
-- 效果发动目标判定：记录被丢弃的怪兽组并设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=eg:Filter(s.cfilter,nil,tp)
	-- 检查额外卡组是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg) end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：把效果怪兽以外的融合怪兽从额外卡组当作通常怪兽特殊召唤，赋予不能直接攻击并限制只能发动不死族怪兽效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject()
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg)
	sg:DeleteGroup()
	local tc=g:GetFirst()
	-- 将选中的怪兽表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 当作通常怪兽卡使用特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"当作通常怪兽卡使用"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_CARD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(TYPE_NORMAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个回合，这个效果特殊召唤的怪兽不能直接攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的后续流程处理
	Duel.SpecialSummonComplete()
	-- 自己不能把不死族以外的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.actlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册本回合怪兽效果发动的限制
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件：不能把不死族以外的怪兽的效果发动
function s.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsRace(RACE_ZOMBIE)
end
