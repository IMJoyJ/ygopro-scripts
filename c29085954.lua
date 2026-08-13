--No.78 ナンバーズ・アーカイブ
-- 效果：
-- 1星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的额外卡组的卡由对方随机选1张。那是「No.1」～「No.99」其中任意种的「No.」怪兽的场合，那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。这个效果在对方回合也能发动。
function c29085954.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用任意2只1星怪兽叠放（超量召唤条件）。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- 对应效果原文：①：1回合1次，把这张卡1个超量素材取除才能发动。自己的额外卡组的卡由对方随机选1张。那是「No.1」～「No.99」其中任意种的「No.」怪兽的场合，那只怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29085954,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c29085954.cost)
	e1:SetTarget(c29085954.sptg)
	e1:SetOperation(c29085954.spop)
	c:RegisterEffect(e1)
end
-- 将该卡的No.编号记录为78，使「No.1～99」相关判定能识别此卡。
aux.xyz_number[29085954]=78
-- 发动代价处理：检查并取除这张卡的1个超量素材（作为发动代价）。
function c29085954.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的额外卡组怪兽：持有「No.1～99」编号且为「No.」怪兽，能够以这张卡为素材进行超量召唤，并且有额外卡组怪兽可用的特殊召唤区域。
function c29085954.filter(c,e,tp,mc)
	-- 获取候选卡的No.编号（若非No.卡则为nil）。
	local no=aux.GetXyzNumber(c)
	return no and no>=1 and no<=99 and c:IsSetCard(0x48)
		and mc:IsCanBeXyzMaterial(c)
		-- 确认该卡可以以超量召唤方式特殊召唤，且自己场上存在可供额外卡组怪兽出场的空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标合法性检查：自己的怪兽存在必须作为超量素材的限制时仍满足条件，且额外卡组存在符合条件的No.怪兽。
function c29085954.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在受“必须作为超量素材”效果影响的卡，以确认素材可用。
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1张满足筛选条件的「No.」怪兽。
		and Duel.IsExistingMatchingCard(c29085954.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置效果处理信息：将会从额外卡组特殊召唤1只怪兽（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：随机选择对方从己方额外卡组选1张，若为符合条件的「No.」怪兽则将其重叠在自己场上这张卡上当作超量召唤特殊召唤，并追加结束阶段除外的效果和本回合不能特殊召唤的限制。
function c29085954.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得己方额外卡组的全部卡作为随机选择的候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 确认额外卡组有卡且自己场上没有影响超量素材使用的限制时继续处理。
	if g:GetCount()>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 洗切己方额外卡组，保证随机选择公平。
		Duel.ShuffleExtra(tp)
		local tg=g:RandomSelect(1-tp,1)
		-- 向对方玩家展示随机选出的那张额外卡组卡片。
		Duel.ConfirmCards(1-tp,tg)
		if tg:IsExists(c29085954.filter,1,nil,e,tp,c) then
			local tc=tg:GetFirst()
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的超量素材全部重叠到被特殊召唤的No.怪兽下方作为其超量素材。
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 把发动效果的这张卡自身也作为超量素材叠放在被特殊召唤的No.怪兽下方（满足其超量召唤素材）。
			Duel.Overlay(tc,Group.FromCards(c))
			-- 将被选中的No.怪兽以超量召唤方式表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(29085954,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc:CompleteProcedure()
			-- 对应效果原文：这个效果特殊召唤的怪兽在结束阶段除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c29085954.rmcon)
			e1:SetOperation(c29085954.rmop)
			-- 将结束阶段除外效果注册到场上（由当前效果处理方控制）。
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 对应效果原文：这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 将“不能特殊召唤怪兽”的自肃效果注册给己方（持续到回合结束）。
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段除外效果的发动条件：若被特殊召唤的怪兽仍然存在且带有对应标记（未被重置/离场），则执行除外；否则重置此效果。
function c29085954.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(29085954)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段到时处理：将效果特殊召唤的那只怪兽表侧表示除外。
function c29085954.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将那只被特殊召唤的No.怪兽表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
