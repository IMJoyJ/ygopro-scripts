--戦華史略－孫劉同盟
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的「战华」怪兽的属性是2种类以上的场合，宣言1个属性才能发动。持有宣言的属性的对方场上的全部怪兽直到回合结束时不能把效果发动。
-- ②：对方对怪兽的特殊召唤成功的场合或者自己把「战华」怪兽的效果发动的场合才能发动。自己场上的全部「战华」怪兽的攻击力直到回合结束时上升自己场上的「战华」怪兽数量×300。
function c58116537.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「战华」怪兽的属性是2种类以上的场合，宣言1个属性才能发动。持有宣言的属性的对方场上的全部怪兽直到回合结束时不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58116537,0))
	e1:SetCategory(CATEGORY_ANNOUNCE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,58116537)
	e1:SetCondition(c58116537.actcon)
	e1:SetTarget(c58116537.acttg)
	e1:SetOperation(c58116537.actop)
	c:RegisterEffect(e1)
	-- ②：对方对怪兽的特殊召唤成功的场合或者自己把「战华」怪兽的效果发动的场合才能发动。自己场上的全部「战华」怪兽的攻击力直到回合结束时上升自己场上的「战华」怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58116537,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,58116538)
	e2:SetCondition(c58116537.atkcon)
	e2:SetTarget(c58116537.atktg)
	e2:SetOperation(c58116537.atkop)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c58116537.atkcon2)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「战华」怪兽
function c58116537.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果①的发动条件：自己场上的「战华」怪兽的属性是2种类以上
function c58116537.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local sg=g:Filter(c58116537.cfilter,nil)
	return sg and sg:GetClassCount(Card.GetAttribute)>=2
end
-- 效果①的靶向/宣言处理：检查对方场上表侧表示怪兽的属性，并让玩家宣言其中1个属性
function c58116537.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 若为检查可行性阶段，则需对方场上存在至少1种属性的表侧表示怪兽
	if chk==0 then return aux.GetAttributeCount(g)>0 end
	local tc=g:GetFirst()
	local att=0
	while tc do
		att=bit.bor(att,tc:GetAttribute())
		tc=g:GetNext()
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从对方场上怪兽持有的属性中宣言1个属性
	local ac=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(ac)
end
-- 效果①的运行空间：使对方场上所有持有宣言属性的怪兽直到回合结束时不能发动效果
function c58116537.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local sg=g:Filter(Card.IsAttribute,nil,e:GetLabel())
	if sg:GetCount()<=0 then return end
	local tc=sg:GetFirst()
	while tc do
		-- ②：对方对怪兽的特殊召唤成功的场合或者自己把「战华」怪兽的效果发动的场合才能发动。自己场上的全部「战华」怪兽的攻击力直到回合结束时上升自己场上的「战华」怪兽数量×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		tc=sg:GetNext()
	end
end
-- 过滤条件：自己场上表侧表示的「战华」怪兽
function c58116537.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果②的发动条件1：对方对怪兽的特殊召唤成功
function c58116537.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的靶向处理：检查自己场上是否存在表侧表示的「战华」怪兽
function c58116537.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查可行性阶段，则需自己场上存在至少1只表侧表示的「战华」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58116537.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的运行空间：使自己场上全部「战华」怪兽的攻击力直到回合结束时上升自己场上的「战华」怪兽数量×300
function c58116537.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「战华」怪兽
	local g=Duel.GetMatchingGroup(c58116537.atkfilter,tp,LOCATION_MZONE,0,nil)
	local gc=g:GetCount()
	if gc>0 then
		local tc=g:GetFirst()
		while tc do
			-- 自己场上的全部「战华」怪兽的攻击力直到回合结束时上升自己场上的「战华」怪兽数量×300。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(gc*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
-- 效果②的发动条件2：自己把「战华」怪兽的效果发动
function c58116537.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp
end
