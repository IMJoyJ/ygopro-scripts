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
	-- 记录该卡拥有「群豪世界-真罗万象」这张卡名
	aux.AddCodeList(c,49568943)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：场地区域有「群豪世界-真罗万象」存在的场合或者自己场上有水属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41525660)
	e1:SetCondition(c41525660.spcon)
	e1:SetTarget(c41525660.sptg)
	e1:SetOperation(c41525660.spop)
	c:RegisterEffect(e1)
	-- ①：以这张卡以外的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向那个相邻的怪兽区域移动。
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
-- 过滤函数，用于判断场上是否存在水属性的「群豪」怪兽
function c41525660.cfilter(c)
	return c:IsSetCard(0x17d) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 判断是否满足灵摆效果的发动条件：场地区域有「群豪世界-真罗万象」存在，或自己场上有水属性「群豪」怪兽
function c41525660.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地区域有「群豪世界-真罗万象」存在，或自己场上有水属性「群豪」怪兽
	return Duel.IsEnvironment(49568943) or Duel.IsExistingMatchingCard(c41525660.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置灵摆效果的目标为自身，检查是否可以特殊召唤
function c41525660.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置操作信息，表示将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆效果的特殊召唤操作
function c41525660.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到指定区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 过滤函数，用于判断目标怪兽是否可以移动到相邻区域
function c41525660.filter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 判断目标怪兽左侧区域是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断目标怪兽右侧区域是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置怪兽效果的目标为符合条件的怪兽，检查是否存在可移动的怪兽
function c41525660.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41525660.filter(chkc) end
	-- 检查是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c41525660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要移动的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(41525660,0))  --"请选择移动位置的怪兽"
	-- 选择要移动的怪兽
	Duel.SelectTarget(tp,c41525660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 执行怪兽效果的移动操作
function c41525660.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local flag=0
	local p=tc:GetControler()
	-- 若目标怪兽左侧区域可用，则将该区域加入可选区域
	if seq>0 and Duel.CheckLocation(p,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若目标怪兽右侧区域可用，则将该区域加入可选区域
	if seq<4 and Duel.CheckLocation(p,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if flag==0 then return end
	if p~=tp then flag=flag<<16 end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择要移动到的区域
	local s=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~flag)
	if p~=tp then s=s>>16 end
	local nseq=math.log(s,2)
	-- 将目标怪兽移动到指定位置
	Duel.MoveSequence(tc,nseq)
end
-- 判断是否满足怪兽效果的发动条件：该卡从怪兽区域移出且移动后位置或控制权发生变化
function c41525660.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 过滤函数，用于判断魔法与陷阱区域的卡是否可以特殊召唤
function c41525660.spfilter(c,e,tp)
	local zone=1<<c:GetSequence()
	return c:IsSetCard(0x17d) and c:IsFaceup() and c:GetSequence()<=4 and c:GetOriginalType()&TYPE_MONSTER~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置怪兽效果的目标为符合条件的魔法与陷阱区域的卡，检查是否存在可特殊召唤的卡
function c41525660.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c41525660.spfilter(chkc,e,tp) end
	-- 检查是否存在符合条件的魔法与陷阱区域的卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c41525660.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的卡
	local g=Duel.SelectTarget(tp,c41525660.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤目标卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行怪兽效果的特殊召唤操作
function c41525660.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	local zone=1<<tc:GetSequence()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到指定区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
