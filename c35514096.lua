--ロードブリティッシュ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。
-- ●只有1次可以继续攻击。
-- ●选择场上盖放的1张卡破坏。
-- ●在自己场上把1只「分机衍生物」（机械族·光·4星·攻/守1200）特殊召唤。
function c35514096.initial_effect(c)
	-- 创建一个诱发必发效果，用于在战斗破坏对方怪兽时发动选择效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35514096,0))  --"选择一个效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c35514096.condition)
	e1:SetTarget(c35514096.target)
	e1:SetOperation(c35514096.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否参与了战斗且战斗对象为怪兽
function c35514096.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤场上盖放的卡（即里侧表示的卡）
function c35514096.filter(c)
	return c:IsFacedown()
end
-- 设置效果发动时的选择处理，根据条件决定可选效果并选择一个
function c35514096.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c35514096.filter(chkc) end
	if chk==0 then return true end
	local c=e:GetHandler()
	local t1=c:IsChainAttackable()
	-- 检测场上是否存在盖放的卡（即里侧表示的卡）
	local t2=Duel.IsExistingTarget(c35514096.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检测玩家场上是否有足够的怪兽区域
	local t3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35514097,0,TYPES_TOKEN_MONSTER,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	local op=0
	if t1 or t2 or t3 then
		local m={}
		local n={}
		local ct=1
		if t1 then m[ct]=aux.Stringid(35514096,1) n[ct]=1 ct=ct+1 end  --"只有1次可以继续攻击"
		if t2 then m[ct]=aux.Stringid(35514096,2) n[ct]=2 ct=ct+1 end  --"选择场上盖放的1张卡破坏"
		if t3 then m[ct]=aux.Stringid(35514096,3) n[ct]=3 ct=ct+1 end  --"在自己场上把1只「分机衍生物」特殊召唤"
		-- 让玩家从可选效果中选择一个
		local sp=Duel.SelectOption(tp,table.unpack(m))
		op=n[sp+1]
	end
	e:SetLabel(op)
	if op==2 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上一张盖放的卡作为破坏对象
		local g=Duel.SelectTarget(tp,c35514096.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_DESTROY)
	elseif op==3 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		-- 设置操作信息为特殊召唤效果
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
		-- 设置操作信息为衍生物效果
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		e:SetProperty(0)
		e:SetCategory(0)
	end
end
-- 执行效果发动后的处理，根据选择的效果类型执行对应操作
function c35514096.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==2 then
		-- 获取当前连锁中选择的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		-- 检测玩家场上是否有足够的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 检测玩家是否可以特殊召唤指定的衍生物
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,35514097,0,TYPES_TOKEN_MONSTER,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
		-- 创建一个指定编号的衍生物
		local token=Duel.CreateToken(tp,35514097)
		-- 将创建的衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	elseif e:GetLabel()==1 then
		if c:IsRelateToBattle() then
			-- 使攻击卡可以再进行一次攻击
			Duel.ChainAttack()
		end
	end
end
