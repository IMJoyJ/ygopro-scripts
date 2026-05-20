--聖光の夢魔鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有光属性「梦魔镜」怪兽存在，自己场上的「梦魔镜」怪兽之内除等级最高的怪兽以外的「梦魔镜」怪兽不会成为攻击对象，也不会成为对方的效果的对象。
-- ②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「黯黑之梦魔镜」发动。
function c74665651.initial_effect(c)
	-- 在卡片中注册关联卡号（黯黑之梦魔镜）
	aux.AddCodeList(c,1050355)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把自己的场地区域的这张卡除外才能发动。从手卡·卡组把1张「黯黑之梦魔镜」发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74665651,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,74665651)
	-- 把自己的场地区域的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c74665651.acttg)
	e2:SetOperation(c74665651.actop)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有光属性「梦魔镜」怪兽存在，自己场上的「梦魔镜」怪兽之内除等级最高的怪兽以外的「梦魔镜」怪兽不会成为攻击对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c74665651.limcon)
	e3:SetValue(c74665651.atlimit)
	c:RegisterEffect(e3)
	-- ①：只要自己场上有光属性「梦魔镜」怪兽存在，自己场上的「梦魔镜」怪兽之内除等级最高的怪兽以外的「梦魔镜」怪兽也不会成为对方的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c74665651.limcon)
	e4:SetTarget(c74665651.tglimit)
	-- 限制为不能成为对方的效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 过滤手卡·卡组中可以发动的「黯黑之梦魔镜」
function c74665651.actfilter(c,tp)
	return c:IsCode(1050355) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 结束阶段发动效果的靶向函数，用于检查手卡·卡组是否存在可发动的「黯黑之梦魔镜」
function c74665651.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组是否存在至少1张满足发动条件的「黯黑之梦魔镜」
	if chk==0 then return Duel.IsExistingMatchingCard(c74665651.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
end
-- 结束阶段发动效果的操作函数，处理从手卡·卡组发动「黯黑之梦魔镜」的过程
function c74665651.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“请选择要放置到场上的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡·卡组选择1张满足发动条件的「黯黑之梦魔镜」
	local tc=Duel.SelectMatchingCard(tp,c74665651.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取当前自己场地区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 因规则将原本场地区域的卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使之后的操作不视为同时处理
			Duel.BreakEffect()
		end
		-- 将选中的「黯黑之梦魔镜」在自己的场地区域表侧表示移动并适用其效果（即发动该场地魔法）
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发场地魔法发动的相关事件时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 过滤自己场上表侧表示的光属性「梦魔镜」怪兽
function c74665651.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x131) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 攻击和效果对象限制效果的适用条件（自己场上存在光属性「梦魔镜」怪兽）
function c74665651.limcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的光属性「梦魔镜」怪兽
	return Duel.IsExistingMatchingCard(c74665651.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤自己场上等级比指定等级高的表侧表示「梦魔镜」怪兽
function c74665651.limfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x131) and c:GetLevel()>lv
end
-- 过滤不能被选择为攻击对象的怪兽（自己场上除等级最高以外的「梦魔镜」怪兽）
function c74665651.atlimit(e,c)
	-- 检查该怪兽是否为表侧表示的「梦魔镜」怪兽，且自己场上存在等级比它更高的「梦魔镜」怪兽
	return c:IsFaceup() and c:IsSetCard(0x131) and Duel.IsExistingMatchingCard(c74665651.limfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
-- 过滤不能被选择为效果对象的怪兽（自己场上除等级最高以外的「梦魔镜」怪兽）
function c74665651.tglimit(e,c)
	return c:IsSetCard(0x131)
		-- 并且自己场上存在等级比该怪兽更高的「梦魔镜」怪兽
		and Duel.IsExistingMatchingCard(c74665651.limfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
