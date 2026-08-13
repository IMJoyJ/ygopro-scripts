--十二獣の会局
-- 效果：
-- 「十二兽的会局」的①的效果1回合只能使用1次。
-- ①：以自己场上1张表侧表示的卡为对象才能把这个效果发动。那张卡破坏，从卡组把1只「十二兽」怪兽特殊召唤。
-- ②：这张卡被效果破坏送去墓地的场合，以自己场上1只「十二兽」超量怪兽为对象才能发动。把墓地的这张卡在那只超量怪兽下面重叠作为超量素材。
function c46060017.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「十二兽的会局」的①的效果1回合只能使用1次。①：以自己场上1张表侧表示的卡为对象才能把这个效果发动。那张卡破坏，从卡组把1只「十二兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46060017,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,46060017)
	e2:SetTarget(c46060017.sptg)
	e2:SetOperation(c46060017.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏送去墓地的场合，以自己场上1只「十二兽」超量怪兽为对象才能发动。把墓地的这张卡在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46060017,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c46060017.matcon)
	e3:SetTarget(c46060017.mattg)
	e3:SetOperation(c46060017.matop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡是否为「十二兽」怪兽，且是否能够被本次效果特殊召唤（不无视召唤条件与苏生限制）。
function c46060017.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件和处理准备：确认自己场上存在表侧表示的可选破坏对象（并根据主怪兽区空位数决定可选区域），且卡组存在可特殊召唤的「十二兽」怪兽；满足后选择1张表侧表示的卡作为对象，并登记破坏与特殊召唤的操作信息。
function c46060017.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then
		-- 获取自己主要怪兽区域的可用空格数，用于判断是否因特殊召唤空间不足而需要缩小可选的破坏对象范围。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查在指定区域（场上或主要怪兽区）是否存在至少1张表侧表示且可作为效果对象的卡。
		return Duel.IsExistingTarget(Card.IsFaceup,tp,loc,0,1,nil)
			-- 检查卡组是否存在至少1张满足spfilter的「十二兽」怪兽（即能够被效果特殊召唤的「十二兽」怪兽）。
			and Duel.IsExistingMatchingCard(c46060017.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 向操作者显示“请选择要破坏的卡”的提示信息，用于后续选择卡片的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从自己场上指定区域选择1张表侧表示的卡，并将其登记为当前连锁的效果对象（破坏对象）。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,e:GetLabel(),0,1,1,nil)
	-- 登记操作信息：本次效果预定破坏的对象为g（选中的卡），破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次效果预定从卡组特殊召唤1只怪兽（具体怪兽在效果处理时选择），目标玩家为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若对象仍与效果关联则将其以效果原因破坏；破坏成功且自己主要怪兽区仍有空位时，从卡组选择1只「十二兽」怪兽以表侧表示特殊召唤到自己场上。
function c46060017.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这次效果发动时选择的对象卡，即要破坏的那张自己场上的表侧表示卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联（未被移离场地等），然后以效果原因将其破坏；只有破坏成功后才继续处理特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 效果处理时再次检查自己主要怪兽区是否有空位，若没有空位则终止特殊召唤处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向操作者显示“请选择要特殊召唤的卡”的提示信息，用于后续选择卡组中的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足spfilter条件的「十二兽」怪兽作为实际特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,c46060017.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到操作者自己场上（不无视召唤条件与苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件：判定这张卡被送去墓地的原因是否同时包含“效果破坏”（REASON_EFFECT与REASON_DESTROY）。
function c46060017.matcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 过滤函数：用于选择自己场上的「十二兽」超量怪兽，要求该卡表侧表示、属于「十二兽」字段且为超量怪兽。
function c46060017.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动与对象选择：确认自己场上有表侧表示的「十二兽」超量怪兽可作为对象，且墓地的这张卡能够作为超量素材；然后选择1只符合条件的超量怪兽作为对象。
function c46060017.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46060017.matfilter(chkc) end
	-- 发动时点检查：是否存在至少1只满足条件的「十二兽」超量怪兽，以及墓地的这张卡是否可以作为超量素材叠放。
	if chk==0 then return Duel.IsExistingTarget(c46060017.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向操作者显示“请选择效果的对象”的提示信息，用于后续选择超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作者选择1只自己场上表侧表示的「十二兽」超量怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c46060017.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：本次效果涉及墓地的这张卡离开墓地（作为超量素材重叠），以便正确应对涉及墓地的效果限制。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：确认墓地的这张卡仍与效果关联、可作为超量素材，且对象超量怪兽仍与效果关联、表侧表示且不免疫此效果后，将墓地的此卡重叠到该超量怪兽下面作为超量素材。
function c46060017.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 将墓地的这张卡作为超量素材，叠放在对象超量怪兽下面。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
