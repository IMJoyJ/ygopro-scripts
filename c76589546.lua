--オーバーフロー・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：场上的怪兽被效果破坏时才能发动。这张卡从手卡特殊召唤。2只以上的场上的怪兽被效果破坏时发动的场合，可以再在自己场上把1只「溢出衍生物」（龙族·暗·1星·攻/守0）特殊召唤。
function c76589546.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：场上的怪兽被效果破坏时才能发动。这张卡从手卡特殊召唤。2只以上的场上的怪兽被效果破坏时发动的场合，可以再在自己场上把1只「溢出衍生物」（龙族·暗·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76589546,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,76589546)
	e1:SetCondition(c76589546.spcon)
	e1:SetTarget(c76589546.sptg)
	e1:SetOperation(c76589546.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本在怪兽区域且因效果被破坏的卡
function c76589546.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 发动条件：计算同时被效果破坏的怪兽数量并保存为Label，若数量大于0则可以发动
function c76589546.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c76589546.cfilter,nil)
	e:SetLabel(ct)
	return ct>0
end
-- 效果的目标选择与检测函数
function c76589546.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有空位且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤手卡的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：特殊召唤这张卡，并根据条件决定是否追加特殊召唤衍生物
function c76589546.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于手卡，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查被破坏的怪兽数量是否在2只以上，且自己场上是否有可用的怪兽区域
		and e:GetLabel()>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「溢出衍生物」（龙族·暗·1星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,76589547,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_DARK)
		-- 询问玩家是否选择特殊召唤衍生物
		and Duel.SelectYesNo(tp,aux.Stringid(76589546,1)) then  --"是否特殊召唤衍生物？"
		-- 中断当前效果处理，使后续的衍生物特殊召唤不与此卡的特殊召唤同时处理
		Duel.BreakEffect()
		-- 创建「溢出衍生物」的卡片数据
		local token=Duel.CreateToken(tp,76589547)
		-- 将衍生物在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
