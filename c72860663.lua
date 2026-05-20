--ヴァンパイア・ファシネイター
-- 效果：
-- 包含不死族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。这个回合，自己不是不死族怪兽不能特殊召唤。
-- ②：把自己场上1只「吸血鬼」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c72860663.initial_effect(c)
	-- 为卡片添加连接召唤的手续，需要2-3只怪兽作为素材，且必须包含不死族怪兽
	aux.AddLinkProcedure(c,nil,2,3,c72860663.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。这个回合，自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,72860663)
	e1:SetCondition(c72860663.spcon)
	e1:SetTarget(c72860663.sptg)
	e1:SetOperation(c72860663.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只「吸血鬼」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72860664)
	e2:SetCost(c72860663.ctcost)
	e2:SetTarget(c72860663.cttg)
	e2:SetOperation(c72860663.ctop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件，检查素材组中是否包含至少1只不死族怪兽
function c72860663.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_ZOMBIE)
end
-- 效果①的发动条件，此卡必须是连接召唤成功
function c72860663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的特殊召唤过滤条件，检查卡片是否可以以表侧守备表示特殊召唤
function c72860663.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备，包括检查是否满足发动条件、选择对方墓地的1只怪兽作为对象并设置特殊召唤的操作信息
function c72860663.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c72860663.spfilter(chkc,e,tp) end
	-- 检查自身场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c72860663.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72860663.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理，将对象怪兽在自己场上守备表示特殊召唤，并适用这个回合自己不能特殊召唤不死族以外怪兽的限制
function c72860663.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①锁定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身场上是否有可用怪兽区域，且对象怪兽是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个回合，自己不是不死族怪兽不能特殊召唤。②：把自己场上1只「吸血鬼」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c72860663.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤不死族以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤条件，限制不能特殊召唤非不死族的怪兽
function c72860663.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 效果②的发动代价，设置标签用于后续在Target阶段检测和执行解放操作
function c72860663.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果②解放怪兽的过滤条件，必须是自己场上的「吸血鬼」怪兽，且解放后能腾出足够的怪兽区域来容纳夺取控制权的怪兽，同时对方场上存在可夺取控制权的怪兽
function c72860663.rfilter(c,tp)
	-- 检查卡片是否为「吸血鬼」怪兽，且解放该卡后自身场上是否有可用于控制权转移的怪兽区域
	return c:IsSetCard(0x8e) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在可以改变控制权的怪兽（排除自身）
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,c)
end
-- 效果②的发动准备，处理解放Cost并选择对方场上1只怪兽作为对象，设置控制权转移的操作信息
function c72860663.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在可作为Cost解放的「吸血鬼」怪兽
			return Duel.CheckReleaseGroup(tp,c72860663.rfilter,1,nil,tp)
		else
			-- 检查对方场上是否存在可以改变控制权的怪兽
			return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的「吸血鬼」怪兽作为解放对象
		local sg=Duel.SelectReleaseGroup(tp,c72860663.rfilter,1,1,nil,tp)
		-- 将选择的「吸血鬼」怪兽解放
		Duel.Release(sg,REASON_COST)
	end
	-- 给玩家发送提示信息，提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置控制权转移的操作信息，包含目标卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果②的效果处理，直到结束阶段得到对象怪兽的控制权
function c72860663.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②锁定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 夺取对象怪兽的控制权，该效果直到结束阶段适用
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
