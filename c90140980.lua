--おジャマ・キング
-- 效果：
-- 「扰乱·绿」＋「扰乱·黄」＋「扰乱·黑」
-- 只要这张卡在场上表侧表示存在，选择对方最多3个怪兽区域不能使用。
function c90140980.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「扰乱·绿」＋「扰乱·黄」＋「扰乱·黑」为素材的融合召唤手续
	aux.AddFusionProcCode3(c,12482652,42941100,79335209,true,true)
	-- 只要这张卡在场上表侧表示存在，选择对方最多3个怪兽区域不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(c90140980.disop)
	c:RegisterEffect(e1)
end
-- 执行选择对方最多3个怪兽区域不能使用的具体操作
function c90140980.disop(e,tp)
	-- 获取对方场上未被限制的可用怪兽区域数量
	local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
	if c==0 then return end
	-- 让玩家选择对方场上第1个要禁用的怪兽区域
	local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	-- 若对方场上还有其他可用怪兽区域，询问玩家是否继续选择
	if c>1 and Duel.SelectYesNo(tp,aux.Stringid(90140980,0)) then  --"是否还要选择一个区域？"
		-- 让玩家选择对方场上第2个要禁用的怪兽区域（排除已选区域）
		local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
		dis1=bit.bor(dis1,dis2)
		-- 若对方场上还有其他可用怪兽区域，询问玩家是否继续选择第3个区域
		if c>2 and Duel.SelectYesNo(tp,aux.Stringid(90140980,0)) then  --"是否还要选择一个区域？"
			-- 让玩家选择对方场上第3个要禁用的怪兽区域（排除已选区域）
			local dis3=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
			dis1=bit.bor(dis1,dis3)
		end
	end
	return dis1
end
