--サラマングレイト・オブ・ファイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「炽焰转生炎兽小妖」外的1只4星以下的「转生炎兽」怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能特殊召唤。
-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「炽焰转生炎兽小妖」外的1只4星以下的「转生炎兽」怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，用于筛选满足条件的怪兽
function s.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 效果处理前的准备函数，用于设置效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定效果将把卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行具体效果操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置永续效果，使自己不能特殊召唤非炎属性怪兽直到回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册永续效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，用于判断是否为炎属性怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 战斗开始时的触发条件函数，用于判断是否满足发动条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽不是自己控制，则获取防守怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE)
end
-- 设置破坏效果的目标函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置连锁操作信息，指定效果将破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏效果的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 将目标怪兽破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
