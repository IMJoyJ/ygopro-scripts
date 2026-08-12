--ビクトリー・バイパー XX03
-- 效果：
-- ①：这张卡战斗破坏对方怪兽的场合，从以下效果选择1个发动。
-- ●这张卡的攻击力上升400。
-- ●以场上1张表侧表示的魔法·陷阱卡为对象发动。那张表侧表示卡破坏。
-- ●把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。这张卡变成不在怪兽区域表侧表示存在时这衍生物破坏。
function c93130021.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽的场合，从以下效果选择1个发动。●这张卡的攻击力上升400。●以场上1张表侧表示的魔法·陷阱卡为对象发动。那张表侧表示卡破坏。●把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。这张卡变成不在怪兽区域表侧表示存在时这衍生物破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93130021,0))  --"选择一个效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c93130021.condition)
	e1:SetTarget(c93130021.target)
	e1:SetOperation(c93130021.operation)
	c:RegisterEffect(e1)
end
-- 判定此卡是否在战斗中破坏了怪兽
function c93130021.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤场上表侧表示的魔法·陷阱卡
function c93130021.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择与效果分支判定
function c93130021.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c93130021.filter(chkc) end
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 检查场上是否存在可以作为对象的表侧表示魔法·陷阱卡
	local t1=Duel.IsExistingTarget(c93130021.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查自己场上是否有空余的怪兽区域
	local t2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤与此卡相同属性、种族、等级、攻击力、守备力的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93130022,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
	-- 提示玩家选择要发动的效果分支
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(93130021,0))  --"选择一个效果发动"
	local op=0
	if t1 and t2 then
		-- 玩家在三个效果分支（攻击力上升、破坏魔陷、特招衍生物）中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,2),aux.Stringid(93130021,3))  --"这张卡攻击力上升400/表侧表示魔法·陷阱卡破坏/「子机衍生物」特殊召唤"
	elseif t1 then
		-- 玩家在攻击力上升和破坏魔陷两个效果分支中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,2))  --"这张卡攻击力上升400/表侧表示魔法·陷阱卡破坏"
	elseif t2 then
		-- 玩家在攻击力上升和特招衍生物两个效果分支中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,3))  --"这张卡攻击力上升400/「子机衍生物」特殊召唤"
		if op==1 then op=2 end
	else
		-- 玩家只能选择攻击力上升的效果分支
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1))  --"这张卡攻击力上升400"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张表侧表示的魔法·陷阱卡作为破坏对象
		local g=Duel.SelectTarget(tp,c93130021.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e:SetProperty(0)
		-- 设置特殊召唤效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
		-- 设置衍生物效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(0)
	end
end
-- 效果处理的执行函数，根据玩家选择的分支执行对应的效果
function c93130021.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取在发动阶段选择的破坏对象
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 因效果破坏目标卡片
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		local atk=c:GetAttack()
		local def=c:GetDefense()
		local lv=c:GetLevel()
		local race=c:GetRace()
		local att=c:GetAttribute()
		-- 检查怪兽区域是否有空位，以及此卡是否仍在场上表侧表示存在
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) or c:IsFacedown()
			-- 检查是否仍能特殊召唤衍生物，若不能则结束处理
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,93130022,0,TYPES_TOKEN_MONSTER,atk,def,lv,race,att) then return end
		-- 创建「子机衍生物」卡片
		local token=Duel.CreateToken(tp,93130022)
		c:CreateRelation(token,RESET_EVENT+RESETS_STANDARD)
		-- 将衍生物以表侧攻击表示特殊召唤到场上（分解步骤）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE,EFFECT_FLAG2_OPTION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c93130021.tokenatk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(c93130021.tokendef)
		token:RegisterEffect(e2,true)
		-- 把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(c93130021.tokenlv)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e3,true)
		-- 把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(c93130021.tokenrace)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e4,true)
		-- 把持有一直和这张卡相同种族·属性·等级·攻击力·守备力的1只「子机衍生物」在自己场上特殊召唤。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(c93130021.tokenatt)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e5,true)
		-- 这张卡变成不在怪兽区域表侧表示存在时这衍生物破坏。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_ADJUST)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCondition(c93130021.tokendescon)
		e6:SetOperation(c93130021.tokendesop)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e6,true)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- ●这张卡的攻击力上升400。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(400)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 获取此卡当前的攻击力，用于实时同步给衍生物
function c93130021.tokenatk(e,c)
	return e:GetOwner():GetAttack()
end
-- 获取此卡当前的守备力，用于实时同步给衍生物
function c93130021.tokendef(e,c)
	return e:GetOwner():GetDefense()
end
-- 获取此卡当前的等级，用于实时同步给衍生物
function c93130021.tokenlv(e,c)
	return e:GetOwner():GetLevel()
end
-- 获取此卡当前的种族，用于实时同步给衍生物
function c93130021.tokenrace(e,c)
	return e:GetOwner():GetRace()
end
-- 获取此卡当前的属性，用于实时同步给衍生物
function c93130021.tokenatt(e,c)
	return e:GetOwner():GetAttribute()
end
-- 检查此卡是否已不再与衍生物存在关联（即此卡已不在怪兽区域表侧表示存在）
function c93130021.tokendescon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetOwner():IsRelateToCard(e:GetHandler())
end
-- 破坏衍生物
function c93130021.tokendesop(e,tp,eg,ep,ev,re,r,rp)
	-- 根据规则破坏衍生物
	Duel.Destroy(e:GetHandler(),REASON_RULE)
end
