--HRUM－アルティメット・フォース
-- 效果：
-- ①：以自己场上1只原本属性是光属性而9阶以下的「霍普」超量怪兽为对象才能发动。把1只10阶以上的「No.」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
-- ②：有这张卡在作为超量素材中的「No.99」超量怪兽得到以下效果。
-- ●对方在战斗阶段把怪兽的效果发动时发动（同一连锁上最多1次）。这张卡的超量素材全部取除，对方场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：包含①卡片发动时以自己场上光属性9阶以下「霍普」超量怪兽为对象，将额外卡组10阶以上「No.」超量怪兽重叠在其上特殊召唤，并把这张卡作为素材的效果；以及②作为素材赋予「No.99」超量怪兽对方在战斗阶段发动怪兽效果时，取除全部超量素材并破坏对方所有怪兽的诱发即时效果。
function s.initial_effect(c)
	-- ①：以自己场上1只原本属性是光属性而9阶以下的「霍普」超量怪兽为对象才能发动。把1只10阶以上的「No.」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的「No.99」超量怪兽得到以下效果。●对方在战斗阶段把怪兽的效果发动时发动（同一连锁上最多1次）。这张卡的超量素材全部取除，对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果（超升阶魔法-究极之力）"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上正面表示、原本属性为光属性且9阶以下的「霍普」超量怪兽，且额外卡组有可重叠特殊召唤的「No.」超量怪兽，并满足超量素材限制检测。
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsRankBelow(9) and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0
		-- 且自己额外卡组存在至少1只可以重叠在该怪兽上进行特殊召唤的「No.」超量怪兽。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 且该怪兽必须满足能够被用作超量素材的限制检测。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤条件：额外卡组中10阶以上的「No.」超量怪兽，且目标怪兽能作为其超量素材，并且自己能够进行其特殊召唤。
function s.filter2(c,e,tp,mc)
	return c:IsRankAbove(10) and c:IsSetCard(0x48) and mc:IsCanBeXyzMaterial(c)
		-- 且该额外怪兽能够进行超量召唤的特殊召唤，并且在目标怪兽被重叠的前提下，自己场上有可用空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果①的发动检测与对象选择：以自己场上1只原本属性是光属性且9阶以下的「霍普」超量怪兽为对象才能发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 在效果①发动前，检查自己场上是否存在满足过滤条件的可作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的目标对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只满足过滤条件的「霍普」超量怪兽作为对象。
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：将被重叠怪兽的超量素材转移，并将额外卡组的「No.」超量怪兽在其上重叠特殊召唤，最后把这张卡作为超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的「霍普」超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断该对象怪兽是否满足超量素材的限制检测，若不满足则结束效果处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在额外卡组中选择1只满足条件的10阶以上「No.」超量怪兽进行重叠特殊召唤。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将被重叠的「霍普」超量怪兽原本持有的超量素材重叠到新召唤的怪兽下方作为其超量素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将被重叠的「霍普」超量怪兽自身重叠到新召唤的怪兽下方作为其超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将所选的额外超量怪兽以正面表示特殊召唤，并视作超量召唤。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		if c:IsRelateToChain() then
			c:CancelToGrave()
			-- 如果发动的本魔法卡仍在连锁中，则将其重叠在已特殊召唤的怪兽下方作为其超量素材。
			Duel.Overlay(sc,Group.FromCards(c))
		end
	end
end
-- 赋予超量怪兽的效果的发动条件判定：在战斗阶段中，此卡是「No.99」超量怪兽且对方玩家发动了怪兽效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为战斗阶段，且获得该素材效果的怪兽是否是「No.99」超量怪兽。
	return Duel.IsBattlePhase() and c:IsSetCard(0x2048)
		and ep~=tp and re:IsActiveType(TYPE_MONSTER)
end
-- 赋予超量怪兽的效果的发动检测：破坏对方场上的全部怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家本效果已被发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上所有的怪兽卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁信息：包含破坏对方场上所有怪兽的效果分类，以及要破坏的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 赋予超量怪兽的效果的效果处理：将该怪兽的所有超量素材全部送去墓地，并破坏对方场上的全部怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local og=c:GetOverlayGroup()
		if og:GetCount()==0 then return end
		-- 将该怪兽持有的所有超量素材（包含此卡）全部送去墓地。
		Duel.SendtoGrave(og,REASON_EFFECT)
		-- 获取当前对方场上所有的怪兽卡片组。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 将对方场上所有的怪兽卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
