--ヴァリアンツの忍者－南月
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：场地区域有「群豪世界-真罗万象」存在的场合或者自己场上有水属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：以这张卡以外的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向那个相邻的怪兽区域移动。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以自己的魔法与陷阱区域1张「群豪」怪兽卡为对象才能发动。那张卡在那个正对面的自己的主要怪兽区域特殊召唤。
function c41525660.initial_effect(c)
	-- 给这张卡注册它记载的卡名「群豪世界-真罗万象」（卡号49568943），用于后续判断关联。
	aux.AddCodeList(c,49568943)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡发动、进行灵摆召唤等。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：场地区域有「群豪世界-真罗万象」存在的场合或者自己场上有水属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41525660)
	e1:SetCondition(c41525660.spcon)
	e1:SetTarget(c41525660.sptg)
	e1:SetOperation(c41525660.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：以这张卡以外的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向那个相邻的怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,41525661)
	e2:SetTarget(c41525660.seqtg)
	e2:SetOperation(c41525660.seqop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以自己的魔法与陷阱区域1张「群豪」怪兽卡为对象才能发动。那张卡在那个正对面的自己的主要怪兽区域特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,41525662)
	e3:SetCondition(c41525660.mvcon)
	e3:SetTarget(c41525660.mvtg)
	e3:SetOperation(c41525660.mvop)
	c:RegisterEffect(e3)
end
-- 定义水属性「群豪」怪兽的过滤条件：表侧表示且满足字段和属性。
function c41525660.cfilter(c)
	return c:IsSetCard(0x17d) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 灵摆效果①的发动条件判断：场地区域存在「群豪世界-真罗万象」，或自己场上有符合条件的水属性「群豪」怪兽。
function c41525660.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：场地卡号为49568943的场地存在，或存在满足cfilter的怪兽。
	return Duel.IsEnvironment(49568943) or Duel.IsExistingMatchingCard(c41525660.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 灵摆效果①的发动与目标检查：取得自身将要特殊召唤到的区域（正对面主怪兽区），确认自身可以被特殊召唤到该区域，并设定特殊召唤的操作信息。
function c41525660.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置操作信息为特殊召唤自身，供后续处理及公开信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果①的发动处理：若自身仍与效果关联，则将其特殊召唤到对应区域。
function c41525660.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 实际执行特殊召唤，将自身以表侧表示特殊召唤到正对面的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 怪兽效果①的取对象过滤：对象必须位于主要怪兽区域（0-4），且其左侧或右侧相邻格子为空。
function c41525660.filter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 判断对象左侧相邻的怪兽区域是否空置可用。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断对象右侧相邻的怪兽区域是否空置可用。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 怪兽效果①的取目标处理：选择除自身以外的主要怪兽区域1只满足filter的怪兽作为对象。
function c41525660.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41525660.filter(chkc) end
	-- 检查是否存在合法对象（满足filter且可成为效果对象的目标）。
	if chk==0 then return Duel.IsExistingTarget(c41525660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 显示选择提示：「请选择移动位置的怪兽」。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(41525660,0))  --"请选择移动位置的怪兽"
	-- 正式选择目标怪兽，并将其登记为当前效果的对象。
	Duel.SelectTarget(tp,c41525660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 怪兽效果①的解决处理：将对象怪兽移动到其相邻的其中一个空位，由发动者选择方向。
function c41525660.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被选择要移动的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local flag=0
	local p=tc:GetControler()
	-- 若该怪兽的左侧相邻主怪兽区为空，则将左侧格子加入可选移动位置集合。
	if seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若该怪兽的右侧相邻主怪兽区为空，则将右侧格子加入可选移动位置集合。
	if seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if flag==0 then return end
	if p~=tp then flag=flag<<16 end
	-- 显示选择提示：「请选择要移动到的位置」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家从可选位置中选定一个目标格子，返回的是对应位置的数据。
	local s=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~flag)
	if p~=tp then s=s>>16 end
	local nseq=math.log(s,2)
	-- 执行移动，将对象怪兽移动到选定的位置。
	Duel.MoveSequence(tc,nseq)
end
-- 怪兽效果②的发动条件：这张卡原本在主要怪兽区域，且现在仍在主要怪兽区域，但位置序号发生了变化或控制者发生了变化（即移动到其他怪兽区域）。
function c41525660.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 定义魔法·陷阱区域「群豪」怪兽卡的特殊召唤过滤条件：必须是表侧表示、原本为怪兽的「群豪」卡，且能够特殊召唤到其正对面的主要怪兽区域。
function c41525660.spfilter(c,e,tp)
	local zone=1<<c:GetSequence()
	return c:IsSetCard(0x17d) and c:IsFaceup() and c:GetSequence()<=4 and c:GetOriginalType()&TYPE_MONSTER~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 怪兽效果②的取目标处理：从自己的魔法与陷阱区域选择1张满足spfilter的「群豪」怪兽卡作为对象。
function c41525660.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c41525660.spfilter(chkc,e,tp) end
	-- 检查是否存在合法对象（自己的魔陷区有可特殊召唤的「群豪」怪兽卡）。
	if chk==0 then return Duel.IsExistingTarget(c41525660.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 显示选择提示：「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 正式选择目标卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c41525660.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤目标卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果②的解决处理：将选择的「群豪」怪兽卡特殊召唤到其正对面的自己的主要怪兽区域。
function c41525660.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被选择要特殊召唤的「群豪」怪兽卡。
	local tc=Duel.GetFirstTarget()
	local zone=1<<tc:GetSequence()
	if tc:IsRelateToEffect(e) then
		-- 实际执行特殊召唤，将目标卡以表侧表示特殊召唤到正对面的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
