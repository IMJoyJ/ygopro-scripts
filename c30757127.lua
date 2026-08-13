--D-HERO デッドリーガイ
-- 效果：
-- 「命运英雄」怪兽＋暗属性效果怪兽
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，丢弃1张手卡才能发动。从手卡·卡组把1只「命运英雄」怪兽送去墓地。那之后，自己墓地有「命运英雄」怪兽存在的场合，自己场上的全部「命运英雄」怪兽的攻击力直到回合结束时上升自己墓地的「命运英雄」怪兽数量×200。
function c30757127.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为「命运英雄」怪兽1只和暗属性效果怪兽1只，可进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),c30757127.ffilter,true)
	-- 对应效果原文：‘这个卡名的效果1回合只能使用1次。①：自己·对方回合，丢弃1张手卡才能发动。从手卡·卡组把1只「命运英雄」怪兽送去墓地。那之后，自己墓地有「命运英雄」怪兽存在的场合，自己场上的全部「命运英雄」怪兽的攻击力直到回合结束时上升自己墓地的「命运英雄」怪兽数量×200。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30757127,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,30757127)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	-- 设置该效果的发动条件：可在双方回合发动，伤害步骤中仅限伤害计算前发动（满足aux.dscon）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c30757127.atkcost)
	e1:SetTarget(c30757127.atktg)
	e1:SetOperation(c30757127.atkop)
	c:RegisterEffect(e1)
end
c30757127.material_setcode=0xc008
-- 定义融合素材补充筛选：融合素材必须是暗属性且为效果怪兽，对应原文‘暗属性效果怪兽’。
function c30757127.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_EFFECT)
end
-- 定义丢弃手卡的代价筛选：选为代价的手卡必须能丢弃，且丢弃后仍能从手卡·卡组找到1只可送去墓地的「命运英雄」怪兽（排除被丢弃的这张卡）。
function c30757127.cfilter(c,tp)
	-- 同cfilter核心判断：检查存在可丢弃的手卡，同时保证丢弃后仍有可送去墓地的「命运英雄」怪兽可供选择。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c30757127.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c)
end
-- 定义送去墓地的卡片筛选：从手卡·卡组选择1只「命运英雄」怪兽，并且该卡能够被送去墓地。
function c30757127.tgfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义发动代价：丢弃1张手卡作为cost；检测时需存在满足cfilter的手卡，执行时实际丢弃1张。
function c30757127.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测分支：若没有满足条件的手卡则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30757127.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 执行代价：从手卡丢弃1张满足cfilter的卡，原因标记为COST和DISCARD。
	Duel.DiscardHand(tp,c30757127.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
-- 定义效果发动时的处理目标：无取对象；设置操作信息后，效果处理时从手卡·卡组选择1只「命运英雄」怪兽送去墓地。
function c30757127.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预定将1张卡从手卡·卡组送去墓地，供其他卡效果（如星尘龙等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义攻击力上升对象的筛选：自己场上表侧表示的「命运英雄」怪兽。
function c30757127.atkfilter(c)
	return c:IsSetCard(0xc008) and c:IsFaceup()
end
-- 定义墓地计数对象的筛选：自己墓地的「命运英雄」怪兽，用于计算攻击力上升数值。
function c30757127.ctfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)
end
-- 定义效果处理操作：从手卡·卡组选择1只「命运英雄」怪兽送去墓地；成功后，给自己场上全部表侧「命运英雄」怪兽的攻击力上升（墓地「命运英雄」数量×200）直到回合结束。
function c30757127.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 实际从手卡·卡组选择1只满足tgfilter的「命运英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30757127.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 确认选中卡非空、成功以效果送去墓地且该卡确实在墓地，才继续执行攻击力上升处理。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取自己场上全部表侧表示的「命运英雄」怪兽，作为攻击力上升的适用对象。
		local tg=Duel.GetMatchingGroup(c30757127.atkfilter,tp,LOCATION_MZONE,0,nil)
		if tg:GetCount()<=0 then return end
		-- 统计自己墓地中「命运英雄」怪兽的数量，用于计算攻击力上升值。
		local ct=Duel.GetMatchingGroupCount(c30757127.ctfilter,tp,LOCATION_GRAVE,0,nil)
		local tc=tg:GetFirst()
		while tc do
			-- 对应效果原文：‘那之后，自己墓地有「命运英雄」怪兽存在的场合，自己场上的全部「命运英雄」怪兽的攻击力直到回合结束时上升自己墓地的「命运英雄」怪兽数量×200。’
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*200)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=tg:GetNext()
		end
	end
end
