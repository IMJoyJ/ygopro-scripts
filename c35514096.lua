--ロードブリティッシュ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。
-- ●只有1次可以继续攻击。
-- ●选择场上盖放的1张卡破坏。
-- ●在自己场上把1只「分机衍生物」（机械族·光·4星·攻/守1200）特殊召唤。
function c35514096.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。●只有1次可以继续攻击。●选择场上盖放的1张卡破坏。●在自己场上把1只「分机衍生物」（机械族·光·4星·攻/守1200）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35514096,0))  --"选择一个效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c35514096.condition)
	e1:SetTarget(c35514096.target)
	e1:SetOperation(c35514096.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判断：这张卡仍与本次战斗关联，且其战斗对象为怪兽（即战斗破坏了对方怪兽）。
function c35514096.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 筛选场上里侧表示的卡（用于选择要破坏的盖放卡）。
function c35514096.filter(c)
	return c:IsFacedown()
end
-- 效果发动时的目标处理：根据当前满足的条件，让玩家从可用的效果分支中选择1个；若选择破坏盖卡则选择场上1张里侧表示的卡为对象并设置破坏信息；若选择特殊召唤则设置衍生物特殊召唤信息；若选择继续攻击则不设定额外对象；并用e:SetLabel记录选择的分支。
function c35514096.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c35514096.filter(chkc) end
	if chk==0 then return true end
	local c=e:GetHandler()
	local t1=c:IsChainAttackable()
	-- 检查场上是否存在1张以上里侧表示的卡，可作为“破坏盖放卡”选项的对象。
	local t2=Duel.IsExistingTarget(c35514096.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查自己主要怪兽区是否有空位，用于特殊召唤衍生物。
	local t3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能够特殊召唤1只「分机衍生物」（机械族·光·4星·攻/守1200）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35514097,0,TYPES_TOKEN_MONSTER,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	local op=0
	if t1 or t2 or t3 then
		local m={}
		local n={}
		local ct=1
		if t1 then m[ct]=aux.Stringid(35514096,1) n[ct]=1 ct=ct+1 end  --"只有1次可以继续攻击"
		if t2 then m[ct]=aux.Stringid(35514096,2) n[ct]=2 ct=ct+1 end  --"选择场上盖放的1张卡破坏"
		if t3 then m[ct]=aux.Stringid(35514096,3) n[ct]=3 ct=ct+1 end  --"在自己场上把1只「分机衍生物」特殊召唤"
		-- 弹出选项菜单，让玩家选择要发动的效果（继续攻击/破坏盖卡/特殊召唤衍生物），返回所选选项的序号。
		local sp=Duel.SelectOption(tp,table.unpack(m))
		op=n[sp+1]
	end
	e:SetLabel(op)
	if op==2 then
		-- 提示玩家选择要破坏的里侧表示卡（选择提示消息：请选择要破坏的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张里侧表示的卡作为效果对象，并将其登记为当前连锁的对象。
		local g=Duel.SelectTarget(tp,c35514096.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置本次连锁的操作信息：破坏类别，预定破坏1张卡（即所选对象）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_DESTROY)
	elseif op==3 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		-- 设置本次连锁的操作信息：特殊召唤类别，预定特殊召唤1只怪兽（对象处理时确定）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
		-- 设置本次连锁的操作信息：衍生物类别，预定生成1只衍生物。
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		e:SetProperty(0)
		e:SetCategory(0)
	end
end
-- 效果处理时的实际操作：根据发动时选择的分支执行相应效果——若选择破坏（label=2），将对象卡破坏；若选择特殊召唤（label=3），在自己场上特殊召唤1只「分机衍生物」；若选择继续攻击（label=1），此卡获得1次追加攻击机会。
function c35514096.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==2 then
		-- 获取发动时选择的对象卡（破坏目标）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 以卡的效果为原因将对象卡破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		-- 处理时再次检查自己主要怪兽区是否有空位，若没有空位则不能特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 或者玩家已不能特殊召唤该衍生物；若上述任一条件不满足，则直接结束效果处理。
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,35514097,0,TYPES_TOKEN_MONSTER,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then return end
		-- 在自己场上生成1只「分机衍生物」（机械族·光·4星·攻/守1200）的衍生物token。
		local token=Duel.CreateToken(tp,35514097)
		-- 将生成的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	elseif e:GetLabel()==1 then
		if c:IsRelateToBattle() then
			-- 使这张卡获得1次追加攻击机会（可以继续进行1次攻击）。
			Duel.ChainAttack()
		end
	end
end
