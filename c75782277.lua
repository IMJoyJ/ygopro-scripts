--ハーピィの狩場
-- 效果：
-- ①：场上的鸟兽族怪兽的攻击力·守备力上升200。
-- ②：自己或对方把「鹰身女郎」或「鹰身女郎三姐妹」召唤·特殊召唤的场合，那玩家以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
function c75782277.initial_effect(c)
	-- 注册卡片关联密码，表明本卡效果中记载了「鹰身女郎三姐妹」的卡名。
	aux.AddCodeList(c,12206212)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己或对方把「鹰身女郎」或「鹰身女郎三姐妹」召唤·特殊召唤的场合，那玩家以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(75782277,0))  --"魔陷破坏"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCode(EVENT_CUSTOM+75782277)
	e4:SetTarget(c75782277.target)
	e4:SetOperation(c75782277.operation)
	c:RegisterEffect(e4)
	-- ①：场上的鸟兽族怪兽的攻击力·守备力上升200。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	-- 设置永续效果的影响对象为鸟兽族怪兽。
	e5:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WINDBEAST))
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetValue(200)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	if not c75782277.global_check then
		c75782277.global_check=true
		-- ②：自己或对方把「鹰身女郎」或「鹰身女郎三姐妹」召唤·特殊召唤的场合，那玩家以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c75782277.check)
		-- 注册全局环境效果，用于监听通常召唤成功事件。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册全局环境效果，用于监听特殊召唤成功事件。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 召唤·特殊召唤成功时的检查函数，筛选出被召唤的「鹰身女郎」或「鹰身女郎三姐妹」，并根据召唤玩家分流触发自定义事件。
function c75782277.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	while tc do
		if tc:IsFaceup() and tc:IsCode(76812113,12206212) then
			if tc:IsControler(0) then g1:AddCard(tc) else g2:AddCard(tc) end
		end
		tc=eg:GetNext()
	end
	-- 如果自己召唤了符合条件的怪兽，则触发自定义事件，并将触发玩家参数设为0（自己）。
	if g1:GetCount()>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+75782277,re,r,rp,0,0) end
	-- 如果对方召唤了符合条件的怪兽，则触发自定义事件，并将触发玩家参数设为1（对方）。
	if g2:GetCount()>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+75782277,re,r,rp,1,0) end
end
-- 过滤函数，筛选场上的魔法·陷阱卡。
function c75782277.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备与目标选择（由于是必发效果，chk==0时直接返回true）。
function c75782277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c75782277.filter(chkc) end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由发动效果的玩家选择场上1张魔法·陷阱卡作为对象。
	local g=Duel.SelectTarget(tp,c75782277.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理为破坏所选的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数，将选中的对象卡破坏。
function c75782277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象卡因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
