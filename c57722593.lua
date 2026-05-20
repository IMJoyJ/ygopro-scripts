--木花咲弥
-- 效果：
-- 这张卡不能通常召唤。自己场上有灵魂怪兽存在的场合才能特殊召唤。这个方法的「木花咲弥」的特殊召唤1回合只能有1次。
-- ①：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1只灵魂怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。
function c57722593.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册灵魂怪兽在特殊召唤成功的回合的结束阶段回到持有者手卡的效果。
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
	-- 这张卡不能通常召唤。自己场上有灵魂怪兽存在的场合才能特殊召唤。这个方法的「木花咲弥」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57722593+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c57722593.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，把墓地的这张卡除外，以自己场上1只灵魂怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能把场上发动的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57722593,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置效果发动成本为将墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c57722593.acttg)
	e3:SetOperation(c57722593.actop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的灵魂怪兽。
function c57722593.sprfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 特殊召唤规则的条件判定函数。
function c57722593.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的灵魂怪兽。
		and Duel.IsExistingMatchingCard(c57722593.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示的灵魂怪兽。
function c57722593.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
-- 效果②的发动准备与目标选择函数。
function c57722593.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57722593.cfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示灵魂怪兽。
	if chk==0 then return Duel.IsExistingTarget(c57722593.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的灵魂怪兽作为对象并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c57722593.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理（效果运行）函数。
function c57722593.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只表侧表示怪兽不能把场上发动的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
