--氷水帝エジル・ラーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把其他的1张「冰水」卡或者1只水属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「冰水衍生物」（水族·水·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡只要有装备卡装备，卡名当作「冰水底 铬离子少女摇篮」使用。
function c18494511.initial_effect(c)
	-- 记录该卡牌具有「冰水底 铬离子少女摇篮」的卡号，用于效果识别
	aux.AddCodeList(c,7142724)
	-- ①：从手卡把其他的1张「冰水」卡或者1只水属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「冰水衍生物」（水族·水·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18494511,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18494511)
	e1:SetCost(c18494511.spcost)
	e1:SetTarget(c18494511.sptg)
	e1:SetOperation(c18494511.spop)
	c:RegisterEffect(e1)
	-- 设置该卡在装备有装备卡时视为「冰水底 铬离子少女摇篮」
	aux.EnableChangeCode(c,7142724,LOCATION_MZONE,c18494511.codecon)
end
-- 过滤函数，用于判断手牌中是否包含「冰水」卡或水属性怪兽且可丢弃
function c18494511.costfilter(c)
	local b1=c:IsSetCard(0x16c)
	local b2=c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER)
	return (b1 or b2) and c:IsDiscardable()
end
-- 检查手牌中是否存在满足条件的卡并将其丢弃作为发动代价
function c18494511.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18494511.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中丢弃一张满足条件的卡
	Duel.DiscardHand(tp,c18494511.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 设置发动效果时的处理目标，检查是否可以特殊召唤此卡
function c18494511.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的主函数，执行特殊召唤并可能召唤衍生物
function c18494511.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查是否可以特殊召唤衍生物
		if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,18494512,0x16c,TYPES_TOKEN_MONSTER,0,0,3,RACE_AQUA,ATTRIBUTE_WATER)
			-- 询问玩家是否要特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(18494511,1)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 创建一个「冰水衍生物」
			local token=Duel.CreateToken(tp,18494512)
			-- 将创建的衍生物特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 为召唤出的衍生物添加效果，使其在场时阻止非水属性怪兽从额外卡组特殊召唤
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(c18494511.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 完成特殊召唤步骤，结束效果处理
			Duel.SpecialSummonComplete()
		end
	end
end
-- 限制非水属性怪兽从额外卡组特殊召唤的效果函数
function c18494511.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断该卡是否装备有装备卡
function c18494511.codecon(e)
	return e:GetHandler():GetEquipCount()>0
end
