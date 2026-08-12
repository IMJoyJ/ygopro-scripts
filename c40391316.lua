--おジャマ・ナイト
-- 效果：
-- 「扰乱」怪兽×2
-- ①：这张卡在怪兽区域表侧表示存在期间，指定没有使用的对方的怪兽区域最多2处，那些区域不能使用。
function c40391316.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个属于「扰乱」的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf),2,true)
	-- ①：这张卡在怪兽区域表侧表示存在期间，指定没有使用的对方的怪兽区域最多2处，那些区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetOperation(c40391316.disop)
	c:RegisterEffect(e2)
end
-- 定义区域无效化操作函数，用于处理对方怪兽区域的禁用逻辑
function c40391316.disop(e,tp)
	-- 获取对方场上可用的怪兽区域数量
	local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
	if c==0 then return end
	-- 选择一个对方未使用的怪兽区域并禁用
	local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	-- 判断是否选择第二个区域，若选择则继续执行
	if c>1 and Duel.SelectYesNo(tp,aux.Stringid(40391316,0)) then  --"是否还要选择一个区域？"
		-- 选择第二个对方未使用的怪兽区域并禁用
		local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
		dis1=bit.bor(dis1,dis2)
	end
	return dis1
end
