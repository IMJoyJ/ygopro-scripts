--おジャマ・ナイト
-- 效果：
-- 「扰乱」怪兽×2
-- ①：这张卡在怪兽区域表侧表示存在期间，指定没有使用的对方的怪兽区域最多2处，那些区域不能使用。
function c40391316.initial_effect(c)
	c:EnableReviveLimit()
	-- 以2只「扰乱」怪兽为融合素材，为这张卡添加融合召唤手续；其中FilterBoolFunction用于筛选融合素材必须满足「扰乱」字段条件。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf),2,true)
	-- ①：这张卡在怪兽区域表侧表示存在期间，指定没有使用的对方的怪兽区域最多2处，那些区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetOperation(c40391316.disop)
	c:RegisterEffect(e2)
end
-- 该效果操作函数用于计算并返回对方场上应无效的怪兽区域标记：先获取对方可用主要怪兽区域数量，若为0则返回空；否则选择第一个要无效的区域，若对方仍有第二个可用区域且玩家确认则再选择第二个，将两个区域标记合并后返回，作为EFFECT_DISABLE_FIELD的无效区域。
function c40391316.disop(e,tp)
	-- 获取对方（1-tp）场上可用的主要怪兽区域空格数；PLAYER_NONE表示不限定使用玩家，reason为0表示正常情况，用于判断最多能无效的区域数量。
	local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
	if c==0 then return end
	-- 让控制者tp从对方主要怪兽区域中选择1个当前没有使用的空格，返回其位置标记dis1，作为第一个不能使用的区域。
	local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	-- 如果对方场上可用的主要怪兽区域数量大于1，则询问tp是否再选择一个区域；选择是则继续选第二个，否则只无效1个区域。
	if c>1 and Duel.SelectYesNo(tp,aux.Stringid(40391316,0)) then  --"是否还要选择一个区域？"
		-- 选择对方主要怪兽区域中另一个可用的空格（排除已选的dis1），返回其位置标记dis2；随后将dis1与dis2用按位或合并，表示最终无效的区域集合。
		local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
		dis1=bit.bor(dis1,dis2)
	end
	return dis1
end
