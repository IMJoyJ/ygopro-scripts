--妖刀－不知火
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，以调整以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽和这张卡从墓地除外，把持有和那2只的等级合计相同等级的1只不死族同调怪兽从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c36630403.initial_effect(c)
	-- 对应效果原文：这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在的场合，以调整以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽和这张卡从墓地除外，把持有和那2只的等级合计相同等级的1只不死族同调怪兽从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,36630403)
	-- 设置效果的发动条件为辅助函数aux.exccon，即这张卡送去墓地的回合不能发动该效果。
	e1:SetCondition(aux.exccon)
	e1:SetTarget(c36630403.target)
	e1:SetOperation(c36630403.operation)
	c:RegisterEffect(e1)
end
-- 定义可选择对象的过滤条件：对象必须是等级大于0、不是调整、不死族、可除外，并且额外卡组存在等级合计符合条件的同调怪兽可特殊召唤。
function c36630403.filter1(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and not c:IsType(TYPE_TUNER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
		-- 检查额外卡组是否存在1只满足filter2的怪兽，其等级等于这张卡当前等级加上候选对象等级之和。
		and Duel.IsExistingMatchingCard(c36630403.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
-- 定义额外卡组同调怪兽的筛选条件：等级等于指定等级、不死族、同调怪兽、可被当前效果特殊召唤，且额外卡组怪兽可用的主怪兽区有空格。
function c36630403.filter2(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认从额外卡组特殊召唤该同调怪兽时，额外卡组怪兽可用的主怪兽区空格数量大于0。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标处理：检查自身可除外、墓地存在1只满足条件的不死族怪兽可选，并在选择对象时对对象进行合法性验证。
function c36630403.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36630403.filter1(chkc,e,tp,e:GetHandler():GetLevel()) end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 发动时检查是否存在1张满足filter1的墓地怪兽可以作为效果对象，同时自身可除外。
		and Duel.IsExistingTarget(c36630403.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLevel()) end
	-- 向玩家弹出“请选择要除外的卡”的选择提示消息，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足filter1的不死族怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c36630403.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler():GetLevel())
	g:AddCard(e:GetHandler())
	-- 设置操作信息：本次效果将除外对象怪兽和这张卡（共2张），类别为除外，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,LOCATION_GRAVE)
	-- 设置操作信息：本次效果还将进行1次从额外卡组的特殊召唤，类别为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：在双方卡仍与效果关联的前提下，计算等级合计，将两者除外；若除外成功，从额外卡组选择符合条件的同调怪兽特殊召唤。
function c36630403.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的那只对象怪兽（墓地里的不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()+tc:GetLevel()
	local g=Group.FromCards(c,tc)
	-- 将这张卡和对象怪兽以表侧表示除外，且确认实际除外了2张后才继续处理特殊召唤。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
		-- 向玩家弹出“请选择要特殊召唤的卡”的选择提示消息，用于选择额外卡组的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足filter2的怪兽：等级等于合计等级、不死族同调、可特殊召唤且有空格。
		local sg=Duel.SelectMatchingCard(tp,c36630403.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		if sg:GetCount()>0 then
			-- 将选择的同调怪兽以表侧攻击表示特殊召唤到自己的场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
