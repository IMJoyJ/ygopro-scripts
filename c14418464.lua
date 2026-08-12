--ヴァリアンツB－バロン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡是已特殊召唤的场合，以这张卡以外的自己的主要怪兽区域1只「群豪」怪兽为对象才能发动。那只自己怪兽的位置向那个相邻的怪兽区域移动。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡在那个相邻的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
function c14418464.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤、并能作为灵摆卡发动到灵摆区域。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,14418464)
	e1:SetTarget(c14418464.sptg)
	e1:SetOperation(c14418464.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡是已特殊召唤的场合，以这张卡以外的自己的主要怪兽区域1只「群豪」怪兽为对象才能发动。那只自己怪兽的位置向那个相邻的怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,14418465)
	e2:SetCondition(c14418464.seqcon)
	e2:SetTarget(c14418464.seqtg)
	e2:SetOperation(c14418464.seqop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡在那个相邻的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,14418466)
	e3:SetCondition(c14418464.mvcon)
	e3:SetTarget(c14418464.mvtg)
	e3:SetOperation(c14418464.mvop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的目标函数：计算这张灵摆卡正对面的主要怪兽区域，并确认这张卡能否被特殊召唤到该区域。
function c14418464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置本次连锁的操作信息为特殊召唤，对象为这张卡自身，数量为1，用于星尘龙等效果的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果的处理：把这张卡特殊召唤到正对面的主要怪兽区域，然后注册一个持续到回合结束的限制效果，使自己不能特殊召唤非「群豪」怪兽（从额外卡组的特殊召唤除外）。
function c14418464.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 把这张卡以表侧表示特殊召唤到自己正对面的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c14418464.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把特殊召唤限制效果注册给发动玩家，直到回合结束时适用。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的判定函数：不是「群豪」怪兽且不在额外卡组的怪兽不能特殊召唤。
function c14418464.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：这张卡是已特殊召唤的场合才能发动。
function c14418464.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 对象筛选函数：自己主要怪兽区域的表侧表示「群豪」怪兽，且其左右相邻的怪兽区域至少有一个可用空格。
function c14418464.filter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 or not c:IsSetCard(0x17d) or c:IsFacedown() then return false end
	-- 若该怪兽不在最左端且左侧相邻的怪兽区域是空位，则可以向左移动。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 或该怪兽不在最右端且右侧相邻的怪兽区域是空位，则可以向右移动。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 效果①的目标函数：确认自己主要怪兽区域存在这张卡以外可移动的「群豪」怪兽，提示玩家选择并将其取为效果对象。
function c14418464.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14418464.filter(chkc) end
	-- 发动条件检查：自己主要怪兽区域是否存在这张卡以外1只可作为对象的可移动「群豪」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c14418464.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送提示消息：请选择要移动位置的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(14418464,0))  --"请选择移动位置的怪兽"
	-- 让玩家从自己主要怪兽区域选择1只这张卡以外的可移动「群豪」怪兽作为效果对象。
	Duel.SelectTarget(tp,c14418464.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果①的处理：取得对象怪兽，计算其左右相邻的可用怪兽区域，让玩家选择要移动到的区域，再把该怪兽移动过去。
function c14418464.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为效果对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local flag=0
	-- 若对象怪兽左侧相邻的主要怪兽区域是空位，则把该区域记入可移动区域的标记。
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若对象怪兽右侧相邻的主要怪兽区域是空位，则把该区域记入可移动区域的标记。
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if flag==0 then return end
	-- 向玩家发送提示消息：请选择要移动到的位置。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家从可移动的主要怪兽区域中选择1个作为移动目标区域。
	local s=Duel.SelectField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	-- 把对象怪兽移动到玩家选择的怪兽区域。
	Duel.MoveSequence(tc,nseq)
end
-- 效果②的触发条件：这张卡之前在怪兽区域、现在仍在怪兽区域，且所处序号（位置）或控制权发生了变化，即这张卡向其他怪兽区域移动的场合。
function c14418464.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 对象筛选函数：灵摆区域的卡，且其相邻的魔法与陷阱区域（左灵摆区对应序号1、右灵摆区对应序号3）可用。
function c14418464.mvfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	-- 若是左灵摆区域（序号0）的卡，且其相邻的魔法与陷阱区域（序号1）可用。
	return (seq==0 and Duel.CheckLocation(tp,LOCATION_SZONE,1))
		-- 或是右灵摆区域（序号4）的卡，且其相邻的魔法与陷阱区域（序号3）可用。
		or (seq==4 and Duel.CheckLocation(tp,LOCATION_SZONE,3))
end
-- 效果②的目标函数：确认双方灵摆区域存在相邻魔法与陷阱区域可用的卡，提示玩家选择并将其取为效果对象。
function c14418464.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c14418464.mvfilter(chkc) end
	-- 发动条件检查：自己或对方的灵摆区域是否存在1张可作为对象且相邻魔法与陷阱区域可用的卡。
	if chk==0 then return Duel.IsExistingTarget(c14418464.mvfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 向玩家发送提示消息：请选择要移动位置的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(14418464,1))  --"请选择移动位置的卡"
	-- 让玩家从自己或对方的灵摆区域选择1张符合条件的卡作为效果对象。
	Duel.SelectTarget(tp,c14418464.mvfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
end
-- 效果②的处理：取得对象卡，确认其处于灵摆区域，计算相邻的魔法与陷阱区域序号，把该卡以表侧表示移动到该区域并使其当作永续魔法卡使用。
function c14418464.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为效果对象的那张灵摆区域的卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq~=0 and seq~=4 then return end
	local nseq=0
	if seq==0 then nseq=1 end
	if seq==4 then nseq=3 end
	-- 把对象卡以表侧表示移动到其相邻的魔法与陷阱区域，移动成功则继续后续处理。
	if Duel.MoveToField(tc,tp,tc:GetControler(),LOCATION_SZONE,POS_FACEUP,true,1<<nseq) then
		-- 那张卡在那个相邻的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
