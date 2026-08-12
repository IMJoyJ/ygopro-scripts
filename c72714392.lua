--BF－大旆のヴァーユ
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不能作为同调素材。
-- ②：这张卡在墓地存在的场合，以调整以外的自己墓地1只「黑羽」怪兽为对象才能发动。那只怪兽和这张卡从墓地除外，把持有和那2只的等级合计相同等级的1只「黑羽」同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c72714392.initial_effect(c)
	-- ②：这张卡在墓地存在的场合，以调整以外的自己墓地1只「黑羽」怪兽为对象才能发动。那只怪兽和这张卡从墓地除外，把持有和那2只的等级合计相同等级的1只「黑羽」同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72714392,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(c72714392.target)
	e1:SetOperation(c72714392.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在怪兽区域存在，不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	-- 设置不能作为同调素材的限制效果始终适用
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中满足条件的非调整「黑羽」怪兽（等级大于0、可除外，且额外卡组存在对应等级的「黑羽」同调怪兽）
function c72714392.filter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x33) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		-- 检查额外卡组是否存在等级等于该怪兽与本卡等级合计的、可特殊召唤的「黑羽」同调怪兽
		and Duel.IsExistingMatchingCard(c72714392.exfilter,tp,LOCATION_EXTRA,0,1,nil,lv+1,e,tp)
end
-- 过滤额外卡组中满足条件的「黑羽」同调怪兽（等级符合要求、可特殊召唤，且有可用的额外怪兽区域）
function c72714392.exfilter(c,lv,e,tp)
	return c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有可用于将该额外怪兽特殊召唤的怪兽区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备与目标选择：检查合法对象、进行取对象操作并声明操作信息
function c72714392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72714392.filter(chkc,e,tp) end
	-- 在发动阶段检查自己墓地是否存在除本卡以外的、满足条件的非调整「黑羽」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c72714392.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的非调整「黑羽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72714392.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置当前连锁的操作信息：在墓地除外1张卡（即选择的对象怪兽）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	-- 设置当前连锁的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：将对象怪兽和本卡除外，并从额外卡组特殊召唤对应等级的「黑羽」同调怪兽，最后将其效果无效化
function c72714392.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local rg=Group.FromCards(c,tc)
	-- 将本卡和对象怪兽以表侧表示除外，并检查是否成功除外了2张卡
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只等级等于除外的2只怪兽等级合计（对象怪兽等级 + 本卡等级1）的「黑羽」同调怪兽
		local sg=Duel.SelectMatchingCard(tp,c72714392.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetLevel()+1,e,tp)
		local sc=sg:GetFirst()
		-- 将选择的同调怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
		if sc and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
	end
end
