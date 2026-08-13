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
-- 对象过滤函数：读取对象阶级，要求对象是表侧表示的超量怪兽，同时额外卡组存在符合条件的升阶候选，且对象没有受到“不能成为超量素材”的限制。
function c47660516.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组中是否存在至少1只满足filter2条件的「混沌No.」或「混沌超量」怪兽，用于判断当前对象是否有可升阶的目标。
		and Duel.IsExistingMatchingCard(c47660516.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetRace(),c:GetCode())
		-- 确认对象怪兽仍可作为超量素材；若受到必须成为素材或不能成为素材等限制，则不满足条件。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组候选怪兽的过滤：先处理特殊规则限制，再要求候选怪兽阶级与对象相同、种族相同、属于「混沌No.」/「混沌超量」字段、对象能成为其超量素材，并满足超量召唤特殊召唤条件和额外怪兽区空位。
function c47660516.filter2(c,e,tp,mc,rk,rc,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsSetCard(0x1048,0x1073) and mc:IsCanBeXyzMaterial(c)
		-- 确认候选怪兽可以被当前效果以超量召唤形式特殊召唤，并且对象作为素材离开后额外怪兽区仍有足够空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 发动时的目标选择函数：校验对象合法性、选择自己场上1只符合条件的超量怪兽作为对象，并登记从额外卡组特殊召唤的操作信息。
function c47660516.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47660516.filter1(chkc,e,tp) end
	-- 发动合法检查：自己场上存在至少1只可以作为对象且能进行本次升阶的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c47660516.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择对象的提示消息，显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只符合条件的超量怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c47660516.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果会从额外卡组将1只怪兽特殊召唤，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：取出对象并确认其仍合法后，从额外卡组选择升阶目标，将对象原有素材和对象本身叠放，以超量召唤方式特殊召唤升阶怪兽；若对方场上有超量素材，则再追加转移1个素材。
function c47660516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的那只自己场上的超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次确认对象仍可作为超量素材；若对象已受到不能作为素材的效果影响，则本次效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择特殊召唤怪兽的提示消息，显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选出1只符合条件的升阶怪兽，候选条件使用对象的阶级+1、种族和当前卡号等参数。
	local g=Duel.SelectMatchingCard(tp,c47660516.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetRace(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的全部超量素材先叠放到升阶后的怪兽下方，使其继承原有素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的超量怪兽自身叠放在升阶后的怪兽下方，作为超量召唤的素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤的方式将升阶后的怪兽表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 检查对方场上是否存在任意超量素材，若有则继续后续追加素材的处理。
		if Duel.GetOverlayCount(tp,0,1)~=0 then
			-- 中断当前效果处理，使后续转移对方素材的处理被视为不同时点，避免错失时点。
			Duel.BreakEffect()
			-- 获取对方场上的全部超量素材，作为可以转移的候选集合。
			local g1=Duel.GetOverlayGroup(tp,0,1)
			-- 向玩家发送选择提示，显示“请选择要转移的素材”。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47660516,0))  --"请选择要转移的素材"
			local mg2=g1:Select(tp,1,1,nil)
			local oc=mg2:GetFirst():GetOverlayTarget()
			-- 将选中的1个对方超量素材叠放到升阶后的怪兽下方，成为其超量素材。
			Duel.Overlay(sc,mg2)
			-- 对原持有该素材的超量怪兽单独触发一次“去除超量素材”的时点，使其自身能响应素材被取走。
			Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
			-- 以原持有该素材的怪兽为来源广播“去除超量素材”时点，让场上其他卡也能响应这次素材转移。
			Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
	end
end
