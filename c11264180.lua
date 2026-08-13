--TGX1－HL
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的攻击力·守备力变成一半，场上存在的1张魔法·陷阱卡破坏。
function c11264180.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的攻击力·守备力变成一半，场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：只能在伤害步骤内且伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11264180.target)
	e1:SetOperation(c11264180.activate)
	c:RegisterEffect(e1)
end
-- 定义目标怪兽的筛选条件：表侧表示且卡名带有「科技属」字段。
function c11264180.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
-- 定义可破坏卡的筛选条件：魔法卡或陷阱卡。
function c11264180.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理：选择自己场上1只表侧表示的「科技属」怪兽作为对象，并确认场上存在可破坏的魔法·陷阱卡。
function c11264180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11264180.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「科技属」表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11264180.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查双方场上是否存在至少1张可破坏的魔法·陷阱卡（除本卡外）。
		and Duel.IsExistingMatchingCard(c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示选取表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示的「科技属」怪兽，并设定为连锁对象。
	Duel.SelectTarget(tp,c11264180.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取双方场上所有可破坏的魔法·陷阱卡（本卡除外）作为破坏候选组。
	local dg=Duel.GetMatchingGroup(c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 登记操作信息：效果处理时将破坏1张魔法·陷阱卡，候选范围是dg。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- 效果处理：将对象怪兽的攻击力·守备力变成一半，然后选择并破坏场上1张魔法·陷阱卡。
function c11264180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 选择的怪兽的攻击力变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(math.ceil(tc:GetAttack()/2))
	tc:RegisterEffect(e1)
	-- 选择的怪兽的守备力变成一半。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(math.ceil(tc:GetDefense()/2))
	tc:RegisterEffect(e2)
	-- 向玩家显示选取要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果处理时选择双方场上1张魔法·陷阱卡（本卡除外）作为破坏对象。
	local dg=Duel.SelectMatchingCard(tp,c11264180.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	-- 以效果原因破坏选择的魔法·陷阱卡。
	Duel.Destroy(dg,REASON_EFFECT)
end
