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
-- 判断此卡是否从魔陷区被破坏送入墓地且为对方回合
function c48086335.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断此卡是否为对方回合被破坏送入墓地
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 设置特殊召唤的处理信息
function c48086335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c48086335.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方回合
function c48086335.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 判断目标怪兽是否为古遗物系列且为怪兽卡
function c48086335.filter(c,e)
	if not c:IsSetCard(0x97) or not c:IsType(TYPE_MONSTER) then return false end
	-- 设置选择盖放的处理信息
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1,true)
	local res=c:IsSSetable()
	e1:Reset()
	return res
end
-- 检查是否有满足条件的墓地怪兽可选择
function c48086335.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48086335.filter(chkc,e) end
	-- 检查场上是否有足够的魔陷区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否有满足条件的墓地怪兽
		and Duel.IsExistingTarget(c48086335.filter,tp,LOCATION_GRAVE,0,1,nil,e) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标墓地中的古遗物怪兽
	local g=Duel.SelectTarget(tp,c48086335.filter,tp,LOCATION_GRAVE,0,1,1,nil,e)
	-- 设置将目标怪兽从墓地移至魔陷区的处理信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行将目标怪兽盖放到魔陷区的操作
function c48086335.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以魔法卡形式盖放至魔陷区
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MONSTER_SSET)
		e1:SetValue(TYPE_SPELL)
		tc:RegisterEffect(e1,true)
		-- 将目标怪兽盖放到魔陷区
		Duel.SSet(tp,tc)
		e1:Reset()
	end
end
