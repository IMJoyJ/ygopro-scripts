--ジャイアント・レックス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不能直接攻击。
-- ②：这张卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升除外的自己的恐龙族怪兽数量×200。
function c80280944.initial_effect(c)
	-- ①：这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升除外的自己的恐龙族怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80280944,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,80280944)
	e2:SetTarget(c80280944.sptg)
	e2:SetOperation(c80280944.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动条件与目标确认（检查怪兽区域空位及自身是否可以特殊召唤）
function c80280944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息，表明该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：筛选表侧表示的恐龙族怪兽
function c80280944.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 特殊召唤效果的处理（特殊召唤自身，并根据除外的自己恐龙族怪兽数量上升攻击力）
function c80280944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否仍与效果相关，并尝试以表侧表示特殊召唤自身（作为特殊召唤步骤的第一步）
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取自己除外区表侧表示的恐龙族怪兽数量
		local ct=Duel.GetMatchingGroupCount(c80280944.filter,tp,LOCATION_REMOVED,0,nil)
		if ct>0 then
			-- 这个效果特殊召唤的这张卡的攻击力上升除外的自己的恐龙族怪兽数量×200。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
	-- 完成特殊召唤的后续处理（使特殊召唤正式生效）
	Duel.SpecialSummonComplete()
end
