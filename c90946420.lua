--百鬼羅刹大重畳
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只超量怪兽为对象才能发动。把1只「哥布林」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
-- ②：把墓地的这张卡除外，以自己场上1只「哥布林」超量怪兽和自己或对方的墓地1张卡为对象才能发动。把成为对象的墓地的卡作为成为对象的场上的怪兽的超量素材。
local s,id,o=GetID()
-- 初始化「百鬼罗刹大重叠」的效果：注册①的卡片发动升阶超量召唤效果以及②在墓地将自身除外补充超量素材的诱发即时效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只超量怪兽为对象才能发动。把1只「哥布林」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外，以自己场上1只「哥布林」超量怪兽和自己或对方的墓地1张卡为对象才能发动。把成为对象的墓地的卡作为成为对象的场上的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动Cost为将墓地的这张卡自身作为Cost表侧表示除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 定义①效果己方对象怪兽过滤函数：检查怪兽是否为表侧表示超量怪兽、满足必须作为超量素材限制，且额外卡组存在可重叠超量召唤的「哥布林」超量怪兽。
function s.filter(c,e,tp)
	-- 检查怪兽是否为表侧表示的超量怪兽、不违反必须作为超量素材限制，且额外卡组存在可对其重叠特召的「哥布林」超量怪兽。
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 定义额外卡组怪兽过滤函数：检查怪兽是否属于「哥布林」(0xac)字段、能以对象怪兽mc为超量素材、能作超量召唤且存在可用场格空位。
function s.filter2(c,e,tp,mc)
	return c:IsSetCard(0xac) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查将对象怪兽mc作为素材离场叠放后，自己场上是否有可用位置从额外卡组特殊召唤该怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果发动对象检查函数：确认这张卡自身可以作为超量素材，且自己场上存在至少1只符合条件的目标超量怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsCanOverlay()
		-- 检查自己怪兽区是否存在至少1只符合条件且可成为效果对象的超量怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己怪兽区选择1只满足条件的超量怪兽作为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 向引擎登记本次连锁预计从自己额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理函数：验证对象怪兽状态后，从额外卡组选1只「哥布林」超量怪兽继承其原有素材并重叠在上面当作超量召唤特殊召唤，再将这张卡自身叠放为超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的当前连锁的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 再次检查对象怪兽是否受到「必须成为超量素材」类效果的合法性限制，若不满足则中止处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择要从额外卡组特殊召唤的「哥布林」超量怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1只满足条件可重叠在对象怪兽上的「哥布林」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的全部超量素材转移并叠放到将要特殊召唤的「哥布林」超量怪兽下方。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象超量怪兽自身也叠放到新「哥布林」超量怪兽下方作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选中的「哥布林」超量怪兽当作超量召唤以表侧表示从额外卡组特殊召唤，并判断特召是否成功。
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				-- 取消这张卡正常的送墓流程后，将这张卡自身叠放到新特殊召唤的「哥布林」超量怪兽下方作为超量素材。
				Duel.Overlay(sc,c)
			end
		end
	end
end
-- 定义②效果己方场上怪兽过滤函数：检查怪兽是否为表侧表示且属于「哥布林」(0xac)字段的超量怪兽。
function s.mfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xac)
end
-- 定义②效果墓地卡片过滤函数：检查墓地卡片是否可以成为超量素材且未被禁止使用。
function s.ofilter(c)
	return c:IsCanOverlay() and not c:IsForbidden()
end
-- ②效果目标检查与选择函数：确认场上存在自己「哥布林」超量怪兽且双方墓地存在可作素材的卡，分别选择1只场上的己方怪兽和1张墓地的卡作为对象并登记离墓操作信息。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在检查能否发动时，确认自己怪兽区存在至少1只表侧「哥布林」超量怪兽对象且双方墓地存在至少1张可作素材的对象卡。
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingTarget(s.ofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择场上表侧表示「哥布林」超量怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己怪兽区选择1只表侧表示的「哥布林」超量怪兽作为第1个对象。
	local g1=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 向玩家发送选择要作为超量素材的墓地卡片提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从双方墓地选择1张满足条件的卡作为第2个对象。
	local g2=Duel.SelectTarget(tp,s.ofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 向引擎登记本次连锁确定将所选墓地卡片从墓地移出（用作超量素材）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- ②效果处理函数：获取仍与连锁保持联系的两个对象卡，若场上的「哥布林」超量怪兽仍由自己控制且墓地对象卡存在，则将其叠放为该怪兽的超量素材。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中所有仍然保持联系的对象卡片组。
	local tg=Duel.GetTargetsRelateToChain()
	local tc1=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local tc2=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc1 and tc1:IsControler(tp) and tc2 then
		-- 将选中的墓地对象卡叠放到选中的自己场上「哥布林」超量怪兽下方作为超量素材。
		Duel.Overlay(tc1,tc2)
	end
end
