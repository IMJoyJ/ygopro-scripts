--白騎士団のロード
local s,id,o=GetID()
-- 初始化效果，注册三个效果
function s.initial_effect(c)
	-- 记录该卡与49306994的关联
	aux.AddCodeList(c,49306994)
	-- 起动效果：手牌发动，可以特殊召唤自身并选择是否处理后续效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 诱发即时效果：攻击宣言时，可将对方攻击怪兽攻击力变为0
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- 触发效果：被破坏时，对对方造成1000伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查墓地是否有3张以上怪物卡可除外作为费用
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 费用处理函数：选择3张怪物卡除外作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外3张怪物卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择3张怪物卡作为除外费用
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标判定函数：检查是否有足够的怪兽区域并能特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：检查手牌或卡组中是否有白骑士团卡组的怪兽可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：检查卡组中是否有49306994可加入手牌
function s.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
-- 效果处理函数：特殊召唤自身并选择是否进行后续处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否能特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查是否有足够的怪兽区域
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌或卡组中是否有白骑士团怪兽可特殊召唤
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		-- 检查卡组中是否有49306994可加入手牌
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local op=0
		if b1 or b2 then
			-- 选择处理选项
			op=aux.SelectFromOptions(tp,
				{true,aux.Stringid(id,3),0},
				{b1,aux.Stringid(id,4),1},
				{b2,aux.Stringid(id,5),2})
		end
		if op~=0 then
			-- 中断当前效果处理，使后续效果视为错时点
			Duel.BreakEffect()
		end
		if op==1 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择一张白骑士团怪兽进行特殊召唤
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的白骑士团怪兽特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择一张49306994加入手牌
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的49306994加入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 确认对方看到加入手牌的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- 攻击宣言时的效果处理函数：判断是否能发动效果
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取当前攻击怪兽
		local a=Duel.GetAttacker()
		-- 获取当前攻击目标
		local at=Duel.GetAttackTarget()
		return (a==c and at or at==c)
			and not c:IsStatus(STATUS_CHAINING)
	end
	-- 设置攻击目标为当前战斗中的目标怪兽
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- 攻击效果处理函数：将对方攻击怪兽攻击力变为0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(1-tp) and tc:GetAttack()>0 then
		-- 将目标怪兽攻击力设为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 破坏时的触发条件判断函数：确认破坏方为对方且自身曾控制过该怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 伤害效果的目标设定函数：设置对方为伤害对象，伤害值为1000
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息为对对方造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果处理函数：对指定玩家造成指定伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
