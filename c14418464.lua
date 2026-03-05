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
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,14418464)
	e1:SetTarget(c14418464.sptg)
	e1:SetOperation(c14418464.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已特殊召唤的场合，以这张卡以外的自己的主要怪兽区域1只「群豪」怪兽为对象才能发动。那只自己怪兽的位置向那个相邻的怪兽区域移动。
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
-- 设置灵摆效果的处理函数
function c14418464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置灵摆效果的处理函数
function c14418464.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到指定区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 创建一个影响玩家的永续效果，禁止玩家在回合结束前特殊召唤非「群豪」怪兽（除从额外卡组的特殊召唤外）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c14418464.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置限制特殊召唤的判断函数
function c14418464.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 设置怪兽效果①的发动条件
function c14418464.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置怪兽效果①的目标筛选函数
function c14418464.filter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 or not c:IsSetCard(0x17d) or c:IsFacedown() then return false end
	-- 判断目标怪兽左侧是否有空位
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断目标怪兽右侧是否有空位
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置怪兽效果①的目标选择函数
function c14418464.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14418464.filter(chkc) end
	-- 判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c14418464.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要移动的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(14418464,0))  --"请选择移动位置的怪兽"
	-- 选择要移动的怪兽
	Duel.SelectTarget(tp,c14418464.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 设置怪兽效果①的处理函数
function c14418464.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local flag=0
	-- 如果目标怪兽左侧有空位，则将该位置标记为可选
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 如果目标怪兽右侧有空位，则将该位置标记为可选
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	if flag==0 then return end
	-- 提示玩家选择目标区域
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	-- 选择目标区域
	local s=Duel.SelectField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	-- 将目标怪兽移动到指定区域
	Duel.MoveSequence(tc,nseq)
end
-- 设置怪兽效果②的发动条件
function c14418464.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 设置怪兽效果②的目标筛选函数
function c14418464.mvfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	-- 判断目标灵摆卡是否可以移动到左侧魔法陷阱区域
	return (seq==0 and Duel.CheckLocation(tp,LOCATION_SZONE,1))
		-- 判断目标灵摆卡是否可以移动到右侧魔法陷阱区域
		or (seq==4 and Duel.CheckLocation(tp,LOCATION_SZONE,3))
end
-- 设置怪兽效果②的目标选择函数
function c14418464.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c14418464.mvfilter(chkc) end
	-- 判断是否存在符合条件的目标灵摆卡
	if chk==0 then return Duel.IsExistingTarget(c14418464.mvfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择要移动的灵摆卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(14418464,1))  --"请选择移动位置的卡"
	-- 选择要移动的灵摆卡
	Duel.SelectTarget(tp,c14418464.mvfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
end
-- 设置怪兽效果②的处理函数
function c14418464.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标灵摆卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence()
	if not seq==0 and not seq==4 then return end
	local nseq=0
	if seq==0 then nseq=1 end
	if seq==4 then nseq=3 end
	-- 将目标灵摆卡移动到魔法陷阱区域
	if Duel.MoveToField(tc,tp,tc:GetControler(),LOCATION_SZONE,POS_FACEUP,true,1<<nseq) then
		-- 将目标灵摆卡转换为永续魔法卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
