--RUM－バリアンズ・フォース
-- 效果：
-- ①：以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。对方场上有超量素材存在的场合，再把那之内的1个作为那只特殊召唤的怪兽的超量素材。
function c47660516.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽或「混沌超量」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。对方场上有超量素材存在的场合，再把那之内的1个作为那只特殊召唤的怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c47660516.target)
	e1:SetOperation(c47660516.activate)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否为正面表示的超量怪兽，并且满足后续检索条件和必须成为超量素材的条件。
function c47660516.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检索满足条件的额外卡组中的「混沌No.」或「混沌超量」怪兽，确保能与目标怪兽构成超量召唤。
		and Duel.IsExistingMatchingCard(c47660516.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetRace(),c:GetCode())
		-- 检测目标怪兽是否满足作为超量素材的条件。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数，用于筛选可以作为超量召唤对象的额外卡组怪兽，包括阶级、种族、卡包、能否成为超量素材、能否特殊召唤以及是否有足够的召唤位置。
function c47660516.filter2(c,e,tp,mc,rk,rc,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsSetCard(0x1048,0x1073) and mc:IsCanBeXyzMaterial(c)
		-- 检查怪兽是否能被特殊召唤并确保有足够召唤位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标为己方场上的1只超量怪兽，并设定操作信息。
function c47660516.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47660516.filter1(chkc,e,tp) end
	-- 判断是否存在满足条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c47660516.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的1只己方场上超量怪兽作为对象。
	Duel.SelectTarget(tp,c47660516.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将特殊召唤1张额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动时的逻辑，包括获取目标、检查是否满足条件并进行后续操作。
function c47660516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 再次确认目标怪兽是否满足作为超量素材的条件。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的1只怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c47660516.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetRace(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到新召唤的怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽本身作为超量素材叠放到新召唤的怪兽上。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤方式将符合条件的怪兽从额外卡组特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 判断对方场上有无超量素材存在。
		if Duel.GetOverlayCount(tp,0,1)~=0 then
			-- 中断当前效果，使后续处理视为错时点。
			Duel.BreakEffect()
			-- 获取对方场上的所有叠放卡。
			local g1=Duel.GetOverlayGroup(tp,0,1)
			-- 提示玩家选择要转移的素材。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47660516,0))  --"请选择要转移的素材"
			local mg2=g1:Select(tp,1,1,nil)
			local oc=mg2:GetFirst():GetOverlayTarget()
			-- 将选中的叠放卡转移到新召唤的怪兽上。
			Duel.Overlay(sc,mg2)
			-- 触发“脱离素材”时点，通知相关效果处理。
			Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
			-- 再次触发“脱离素材”时点，确保所有相关效果正确响应。
			Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
	end
end
