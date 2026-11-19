--ハーピィの狩場
-- 效果：
-- ①：场上的鸟兽族怪兽的攻击力·守备力上升200。
-- ②：自己或对方把「鹰身女郎」或「鹰身女郎三姐妹」召唤·特殊召唤的场合，那玩家以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
function c75782277.initial_effect(c)
	-- 记录该卡效果文上记载了「鹰身女郎」「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,76812113,12206212)
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
	-- 设置永续增益效果的作用对象过滤条件：仅限鸟兽族怪兽
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
		-- 注册全局不入连锁持续效果，监听全场通常召唤成功事件以触发自定义事件
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册全局不入连锁持续效果，监听全场特殊召唤成功事件以触发自定义事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 全局监听回调函数：筛选出表侧表示的「鹰身女郎」或「鹰身女郎三姐妹」，按控制者分别触发对应的自定义事件
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
	-- 若先攻方场上本次召唤·特召了目标怪兽，则以玩家0作为事件玩家触发自定义事件
	if g1:GetCount()>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+75782277,re,r,rp,0,0) end
	-- 若后攻方场上本次召唤·特召了目标怪兽，则以玩家1作为事件玩家触发自定义事件
	if g2:GetCount()>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+75782277,re,r,rp,1,0) end
end
-- 过滤条件函数：筛选魔法卡或陷阱卡
function c75782277.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的必发目标选择函数：由触发事件的玩家从双方场上选择1张魔法·陷阱卡作为对象并登记破坏操作信息
function c75782277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c75782277.filter(chkc) end
	if chk==0 then return true end
	-- 向触发事件的玩家发送选择提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让触发事件的玩家从双方场上选择1张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c75782277.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记操作信息：将会破坏所选对象的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的处理函数：若对象卡仍存在且与效果关联，则将其破坏
function c75782277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果破坏对象魔法·陷阱卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
