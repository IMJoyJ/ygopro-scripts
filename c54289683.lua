--パワーカプセル
-- 效果：
-- 选择自己场上表侧表示存在的1只「胜利蛇XX03」发动。从「胜利蛇XX03」的效果选择1个，作为这张卡的效果适用。
function c54289683.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只「胜利蛇XX03」发动。从「胜利蛇XX03」的效果选择1个，作为这张卡的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54289683.target)
	e1:SetOperation(c54289683.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「胜利蛇XX03」
function c54289683.filter(c)
	return c:IsFaceup() and c:IsCode(93130021)
end
-- 过滤条件：场上表侧表示的魔法·陷阱卡
function c54289683.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择与合法性检查（取对象）
function c54289683.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c54289683.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「胜利蛇XX03」
	if chk==0 then return Duel.IsExistingTarget(c54289683.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「胜利蛇XX03」作为对象
	Duel.SelectTarget(tp,c54289683.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：根据选择的「胜利蛇XX03」的效果进行适用
function c54289683.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的「胜利蛇XX03」
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 检查场上是否存在除这张卡以外的表侧表示魔法·陷阱卡
	local t1=Duel.IsExistingMatchingCard(c54289683.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	-- 检查自己场上是否有怪兽区域的空位
	local t2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤具有该「胜利蛇XX03」当前数值和属性的「子机衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93130022,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute())
	-- 提示玩家选择一个效果发动
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(93130021,0))  --"选择一个效果发动"
	local op=0
	if t1 and t2 then
		-- 玩家从“攻击力上升400”、“破坏表侧魔陷”、“特招子机”三个效果中选择一个适用
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,2),aux.Stringid(93130021,3))  --"这张卡攻击力上升400/表侧表示魔法·陷阱卡破坏/「子机衍生物」特殊召唤"
	elseif t1 then
		-- 玩家从“攻击力上升400”、“破坏表侧魔陷”两个效果中选择一个适用
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,2))  --"这张卡攻击力上升400/表侧表示魔法·陷阱卡破坏"
	elseif t2 then
		-- 玩家从“攻击力上升400”、“特招子机”两个效果中选择一个适用
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1),aux.Stringid(93130021,3))  --"这张卡攻击力上升400/「子机衍生物」特殊召唤"
		if op==1 then op=2 end
	else
		-- 玩家只能选择“攻击力上升400”的效果适用
		op=Duel.SelectOption(tp,aux.Stringid(93130021,1))  --"这张卡攻击力上升400"
	end
	if op==1 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择场上1张表侧表示的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c54289683.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显式示出被选择的卡片
			Duel.HintSelection(g)
			-- 破坏选择的卡片
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local lv=tc:GetLevel()
		local race=tc:GetRace()
		local att=tc:GetAttribute()
		-- 创建「子机衍生物」
		local token=Duel.CreateToken(tp,93130022)
		tc:CreateRelation(token,RESET_EVENT+RESETS_STANDARD)
		-- 将「子机衍生物」以表侧表示特殊召唤到场上（分步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 这只衍生物的攻击力·守备力...常是和这只怪兽相同的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c54289683.tokenatk)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(c54289683.tokendef)
		e2:SetLabelObject(tc)
		token:RegisterEffect(e2,true)
		-- 这只衍生物的...等级...常是和这只怪兽相同的数值。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(c54289683.tokenlv)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e3,true)
		-- 这只衍生物的...种族...常是和这只怪兽相同的数值。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(c54289683.tokenrace)
		e4:SetLabelObject(tc)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e4,true)
		-- 这只衍生物的...属性常是和这只怪兽相同的数值。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(c54289683.tokenatt)
		e5:SetLabelObject(tc)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e5,true)
		-- 这只怪兽不在场上表侧表示存在时，这只衍生物破坏。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_SELF_DESTROY)
		e6:SetCondition(c54289683.tokendes)
		e6:SetLabelObject(tc)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e6,true)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	else
		-- 这张卡攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		tc:RegisterEffect(e1)
	end
end
-- 获取「胜利蛇XX03」的攻击力以用于「子机衍生物」
function c54289683.tokenatk(e,c)
	return e:GetLabelObject():GetAttack()
end
-- 获取「胜利蛇XX03」的守备力以用于「子机衍生物」
function c54289683.tokendef(e,c)
	return e:GetLabelObject():GetDefense()
end
-- 获取「胜利蛇XX03」的等级以用于「子机衍生物」
function c54289683.tokenlv(e,c)
	return e:GetLabelObject():GetLevel()
end
-- 获取「胜利蛇XX03」的种族以用于「子机衍生物」
function c54289683.tokenrace(e,c)
	return e:GetLabelObject():GetRace()
end
-- 获取「胜利蛇XX03」的属性以用于「子机衍生物」
function c54289683.tokenatt(e,c)
	return e:GetLabelObject():GetAttribute()
end
-- 检查「胜利蛇XX03」是否已离开场上（用于判断「子机衍生物」是否自爆）
function c54289683.tokendes(e)
	return not e:GetLabelObject():IsRelateToCard(e:GetHandler())
end
