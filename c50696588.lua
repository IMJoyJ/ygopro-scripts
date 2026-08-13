--GUYダンス
--not fully implemented (require other cards to be updated)
-- 效果：
-- 这个卡名的效果在决斗中只能适用1次。
-- ①：指定没有使用的对方的主要怪兽区域1处才能发动。只要指定的区域是可以使用，对方要在主要怪兽区域把怪兽通常召唤·特殊召唤的场合，不是那个区域不能使用。这个效果直到指定的区域有怪兽被放置为止适用。
function c50696588.initial_effect(c)
	-- 这个卡名的效果在决斗中只能适用1次；①：指定没有使用的对方的主要怪兽区域1处才能发动。只要指定的区域是可以使用，对方要在主要怪兽区域把怪兽通常召唤·特殊召唤的场合，不是那个区域不能使用。这个效果直到指定的区域有怪兽被放置为止适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50696588.cost)
	e1:SetTarget(c50696588.target)
	e1:SetOperation(c50696588.activate)
	c:RegisterEffect(e1)
end
-- 发动代价判定：检查自己本决斗中是否已经适用过此卡名的效果，若已适用则不能发动。
function c50696588.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为代价检查阶段（chk==0），返回“自己场上不存在50696588号标志效果”，用以确保该卡名效果在决斗中只能适用1次。
	if chk==0 then return Duel.GetFlagEffect(tp,50696588)==0 end
end
-- 发动时选择对象：在对方的未使用的怪兽区域中选1处，保存所选区域并告知双方。
function c50696588.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上是否存在至少1个可选的未使用的主要怪兽区域空格（此处以对方玩家视角检查主怪兽区可用空格）。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 让玩家从对方的主要怪兽区域中选择1个未使用的空格，返回所选区域的位置标记并存入效果Label。
	local flag=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	e:SetLabel(flag)
	-- 将所选区域的位置标记以区域提示（HINT_ZONE）的形式展示给双方玩家。
	Duel.Hint(HINT_ZONE,tp,flag)
end
-- 效果处理：读取发动时选择的区域；若该区域现在不可用或本决斗已适用过同名效果，则处理失败。
function c50696588.activate(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabel()
	local seq=math.log(bit.rshift(flag,16),2)
	-- 检查发动时选择的对方主要怪兽区域当前是否仍是可用空格；若不可用则不处理。
	if not Duel.CheckLocation(1-tp,LOCATION_MZONE,seq)
		-- 同时检查自己是否已经适用过此卡名效果（flag标志存在），若已适用则直接结束处理，确保决斗中只能适用1次。
		or Duel.GetFlagEffect(tp,50696588)~=0 then return end
	-- 为自己注册50696588号标志效果，记录该卡名效果已适用，用于后续同名卡不能再次适用。
	Duel.RegisterFlagEffect(tp,50696588,0,0,0)
	-- 只要指定的区域是可以使用，对方要在主要怪兽区域把怪兽通常召唤·特殊召唤的场合，不是那个区域不能使用。这个效果直到指定的区域有怪兽被放置为止适用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTargetRange(0,1)
	e1:SetValue(flag | 0x600060)
	e1:SetCountLimit(1)
	-- 将该限制效果注册到全场环境中，使对方必须使用被指定的主要怪兽区域来通常召唤·特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
