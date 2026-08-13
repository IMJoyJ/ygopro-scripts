--アーティファクト－フェイルノート
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。对方回合中这张卡特殊召唤成功的场合，可以从自己墓地选择1只名字带有「古遗物」的怪兽在自己的魔法与陷阱卡区域盖放。
function c48086335.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48086335,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c48086335.spcon)
	e2:SetTarget(c48086335.sptg)
	e2:SetOperation(c48086335.spop)
	c:RegisterEffect(e2)
	-- 对方回合中这张卡特殊召唤成功的场合，可以从自己墓地选择1只名字带有「古遗物」的怪兽在自己的魔法与陷阱卡区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48086335,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c48086335.setcon)
	e3:SetTarget(c48086335.settg)
	e3:SetOperation(c48086335.setop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否满足从魔法与陷阱卡区域里侧表示被破坏送去墓地的条件，且其上一个控制者为这张卡效果的控制者，用于确定是否在对方回合被破坏。
function c48086335.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 确认这张卡是因为被破坏而送去墓地，且当前回合是对方回合（当前回合玩家不是其控制者）。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果发动时的目标处理：必发效果无需选择对象，直接返回true并登记特殊召唤操作信息。
function c48086335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息登记为特殊召唤这张卡自身，用于让其他卡（如星尘龙）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤：若这张卡仍与效果相关，则将其以表侧表示特殊召唤上场。
function c48086335.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡表侧表示特殊召唤到其控制者场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 第三个效果的发动条件：仅在对方回合（当前回合玩家不是这张卡的控制者）且特殊召唤成功时才能发动。
function c48086335.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即处于对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选条件：对象必须是自己墓地的名字带有「古遗物」的怪兽；通过临时赋予其可作为魔法卡盖放的效果，确认它能够被盖放到魔法与陷阱卡区域。
function c48086335.filter(c,e)
	if not c:IsSetCard(0x97) or not c:IsType(TYPE_MONSTER) then return false end
	-- 可以从自己墓地选择1只名字带有「古遗物」的怪兽在自己的魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1,true)
	local res=c:IsSSetable()
	e1:Reset()
	return res
end
-- 取对象效果的发动判定：检查被选对象是否是自己墓地的古遗物怪兽，且发动时需要自己魔陷区有空位、墓地存在符合条件的对象。
function c48086335.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48086335.filter(chkc,e) end
	-- 确认自己的魔法与陷阱卡区域有空余位置可以盖放。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己墓地存在至少1只满足条件的「古遗物」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c48086335.filter,tp,LOCATION_GRAVE,0,1,nil,e) end
	-- 向玩家显示“请选择要盖放的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1只符合条件的「古遗物」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c48086335.filter,tp,LOCATION_GRAVE,0,1,1,nil,e)
	-- 设置操作信息为让对象离开墓地（CATEGORY_LEAVE_GRAVE），以配合墓地相关的卡片互动。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：取得选择的对象，若其仍与效果相关，则赋予其可作为魔法卡盖放的效果并执行盖放，最后重置临时效果。
function c48086335.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的那只墓地「古遗物」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 在自己的魔法与陷阱卡区域盖放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MONSTER_SSET)
		e1:SetValue(TYPE_SPELL)
		tc:RegisterEffect(e1,true)
		-- 将选中的古遗物怪兽卡片盖放到自己的魔法与陷阱卡区域。
		Duel.SSet(tp,tc)
		e1:Reset()
	end
end
