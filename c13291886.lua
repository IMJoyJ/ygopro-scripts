--ヴァリアンツD－デューク
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：场地区域有「群豪世界-百识公国」存在的场合或者自己场上有炎属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：以魔法与陷阱区域盖放的1张卡为对象才能发动。盖放的那张卡在这个回合不能发动。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以对方的主要怪兽区域1只表侧表示怪兽为对象才能发动。得到那只表侧表示怪兽的控制权。这个效果得到控制权的怪兽不能攻击宣言，不能把效果发动，也当作「群豪」怪兽使用。
function c13291886.initial_effect(c)
	-- 为该卡注册效果文本中记载的「群豪世界-百识公国」（卡号75952542），使代码能识别与该卡名相关的信息。
	aux.AddCodeList(c,75952542)
	-- 为该卡启用灵摆怪兽属性，使其可以作为灵摆卡在灵摆区发动并获得灵摆召唤相关的底层支持。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：场地区域有「群豪世界-百识公国」存在的场合或者自己场上有炎属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,13291886)
	e1:SetCondition(c13291886.spcon)
	e1:SetTarget(c13291886.sptg)
	e1:SetOperation(c13291886.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：以魔法与陷阱区域盖放的1张卡为对象才能发动。盖放的那张卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,13291887)
	e2:SetTarget(c13291886.altg)
	e2:SetOperation(c13291886.alop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以对方的主要怪兽区域1只表侧表示怪兽为对象才能发动。得到那只表侧表示怪兽的控制权。这个效果得到控制权的怪兽不能攻击宣言，不能把效果发动，也当作「群豪」怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,13291888)
	e3:SetCondition(c13291886.mvcon)
	e3:SetTarget(c13291886.mvtg)
	e3:SetOperation(c13291886.mvop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断一张卡是否为表侧表示、炎属性且属于「群豪」（0x17d）字段，用于检查自己场上是否存在符合条件的「群豪」怪兽。
function c13291886.cfilter(c)
	return c:IsSetCard(0x17d) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
-- 灵摆效果的发动条件：场地区域存在「群豪世界-百识公国」，或者自己主要怪兽区域存在表侧表示的炎属性「群豪」怪兽；任一条件满足即可发动。
function c13291886.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前场地是否有「群豪世界-百识公国」（卡号75952542）生效，或者自己场上存在至少1只表侧表示·炎属性·「群豪」怪兽；任一成立即为条件满足。
	return Duel.IsEnvironment(75952542) or Duel.IsExistingMatchingCard(c13291886.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤的目标处理：取得这张卡在灵摆区的格子序号，并检查能否以表侧表示特殊召唤到该格子正对面的自己的主要怪兽区域；可行时登记特殊召唤操作信息。
function c13291886.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 登记本连锁将进行特殊召唤的操作信息（对象为这张卡自身，数量1），供其他卡牌效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则以表侧表示将其特殊召唤到正对面的自己的主要怪兽区域（由原灵摆区序号换算出的格子）。
function c13291886.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到指定主要怪兽区域，不检查召唤条件且不检查苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 过滤函数：判定一张卡是否为魔法与陷阱区域里侧表示且位于通常魔陷区（序号<5，排除场地区），用于选择「魔法与陷阱区域盖放的卡」的对象。
function c13291886.alfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- ①效果的目标选择：以魔法与陷阱区域盖放的1张卡为对象；检查阶段确认对象合法后，提示玩家选择1张符合条件的卡，并将其设为效果对象。
function c13291886.altg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c13291886.alfilter(chkc) end
	-- 发动时检查：场上是否存在至少1张可以成为对象的魔法与陷阱区域里侧盖放卡；存在则发动合法。
	if chk==0 then return Duel.IsExistingTarget(c13291886.alfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家显示选择提示消息，提示内容为自定义文本“请选择要禁止发动的卡”，用于选择对象的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(13291886,0))  --"请选择要禁止发动的卡"
	-- 令玩家从双方魔法与陷阱区域中选择1张里侧盖放卡作为对象，并自动登记为本连锁的对象。
	Duel.SelectTarget(tp,c13291886.alfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
end
-- 效果处理：取回对象卡，若其仍是里侧表示且与效果关联，则给它附加“不能发动效果”的永续效果，持续到回合结束或离场等标准重置时点。
function c13291886.alop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁的效果对象卡（第一个也是唯一一个），即被选择的里侧盖放卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 盖放的那张卡在这个回合不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的触发条件：这张卡从怪兽区域移动后仍处于怪兽区域，且移动前后格子或控制者发生变化（即移到了其他主要怪兽区域），满足“向其他的怪兽区域移动”。
function c13291886.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 过滤函数：判定对方主要怪兽区域的怪兽是否为表侧表示、控制权可以被改变，且位于主要怪兽区域格子（序号≤4，不含额外怪兽区）。
function c13291886.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:GetSequence()<=4
end
-- ②效果发动时的目标选择：以对方主要怪兽区域1只表侧表示怪兽为对象；确认存在合法对象后，提示玩家选择，并登记改变控制权的操作信息。
function c13291886.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c13291886.filter(chkc) end
	-- 发动检查：对方场上是否存在至少1只符合条件的表侧表示怪兽可作为对象；有则可发动。
	if chk==0 then return Duel.IsExistingTarget(c13291886.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示消息，提示内容为系统内置的“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 令玩家从对方主要怪兽区域选择1只符合条件的表侧表示怪兽作为对象，并登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c13291886.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本连锁将进行改变控制权的操作信息（对象为所选怪兽，数量1），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若对象卡仍与效果关联且表侧表示，则取得其控制权；成功后给该怪兽附加不能攻击、不能发动效果、视为「群豪」字段的效果。
function c13291886.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁的效果对象卡，即被选择要改变控制权的对方怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍与效果关联、是否表侧表示，并且是否成功取得控制权；满足条件才赋予后续限制效果。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetControl(tc,tp)~=0 then
		-- 这个效果得到控制权的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_ADD_SETCODE)
		e3:SetValue(0x17d)
		tc:RegisterEffect(e3)
	end
end
