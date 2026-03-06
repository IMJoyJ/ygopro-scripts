--絶解なる獄神門－テルミナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组·额外卡组把1只「狱神」怪兽送去墓地。那之后，可以从卡组把1只天使族·暗属性怪兽加入手卡。这个回合，自己不用「狱神」怪兽不能攻击宣言。
-- ②：自己的「狱神」怪兽和对方怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只对方怪兽里侧除外。
local s,id,o=GetID()
-- 注册两个效果：①效果（发动时处理）和②效果（战斗开始时触发）
function s.initial_effect(c)
	-- ①：从卡组·额外卡组把1只「狱神」怪兽送去墓地。那之后，可以从卡组把1只天使族·暗属性怪兽加入手卡。这个回合，自己不用「狱神」怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「狱神」怪兽和对方怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只对方怪兽里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 效果发动时需要将自身除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断是否为「狱神」怪兽且能送去墓地
function s.tgfilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理时检查是否存在满足条件的「狱神」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「狱神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理信息：将1只「狱神」怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤函数：判断是否为天使族·暗属性怪兽且能加入手卡
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 效果发动时选择1只「狱神」怪兽送去墓地，然后选择是否将1只天使族·暗属性怪兽加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只「狱神」怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的「狱神」怪兽送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查是否存在满足条件的天使族·暗属性怪兽并询问是否加入手卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择1只天使族·暗属性怪兽加入手卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的天使族·暗属性怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 注册一个永续效果：本回合不能攻击宣言
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册永续效果
	Duel.RegisterEffect(e3,tp)
end
-- 判断是否为非「狱神」怪兽
function s.atktg(e,c)
	return not c:IsSetCard(0x1ce)
end
-- 判断是否满足②效果发动条件：己方「狱神」怪兽处于战斗状态且对方怪兽存在
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方处于战斗状态的怪兽
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsSetCard(0x1ce)) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 设置②效果处理信息：将对方怪兽除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return true end
	-- 设置效果处理信息：将对方怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果发动时将对方怪兽除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsType(TYPE_MONSTER) and bc:IsRelateToBattle() then
		-- 将对方怪兽除外
		Duel.Remove(bc,POS_FACEDOWN,REASON_EFFECT)
	end
end
