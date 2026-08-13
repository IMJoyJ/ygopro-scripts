--エクシーズ・リモーラ
-- 效果：
-- ①：这张卡可以把自己场上2个超量素材取除，从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功时，以自己墓地2只鱼族·4星怪兽为对象才能发动。那些鱼族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，也不能作表示形式的变更。把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是水属性怪兽的超量召唤不能使用。
function c43138260.initial_effect(c)
	-- ①：这张卡可以把自己场上2个超量素材取除，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c43138260.spcon)
	e1:SetOperation(c43138260.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功时，以自己墓地2只鱼族·4星怪兽为对象才能发动。那些鱼族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，也不能作表示形式的变更。把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是水属性怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43138260,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c43138260.spcon2)
	e2:SetTarget(c43138260.sptg2)
	e2:SetOperation(c43138260.spop2)
	c:RegisterEffect(e2)
end
-- 特殊召唤手续的规则条件：若用于规则询问的c为空则允许；否则需要该卡控制者的主要怪兽区域有空位，并且其场上存在至少2个可因特殊召唤取除的超量素材。
function c43138260.spcon(e,c)
	if c==nil then return true end
	-- 返回该卡控制者的主要怪兽区域空格数是否大于0，即是否有空位可供特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 进一步检查该卡控制者是否能从自己场上取除2个超量素材（以特殊召唤为理由）。
		and Duel.CheckRemoveOverlayCard(c:GetControler(),1,0,2,REASON_SPSUMMON)
end
-- 特殊召唤手续的处理操作：实际从自己场上取除2个超量素材，完成“自己场上2个超量素材取除”这一代价。
function c43138260.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 执行取除操作：由tp从自己场上选择2张超量素材移除，移除理由为特殊召唤。
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_SPSUMMON)
end
-- ②效果的发动条件：判定这张卡是否通过①记载的方法特殊召唤成功（即召唤类型为特殊召唤且带有SUMMON_VALUE_SELF标识）。
function c43138260.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义墓地可用目标怪兽的过滤条件：必须是鱼族、4星，且可以被当前效果以表侧守备表示特殊召唤。
function c43138260.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动与选择对象处理：若未指定对象，检查没有“不能同时特殊召唤2只以上怪兽”的效果影响、主要怪兽区至少2个空位、墓地存在至少2只符合条件的鱼族·4星怪兽；若指定对象，则验证其位于自己墓地且满足条件。
function c43138260.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43138260.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查tp的主要怪兽区域是否有2个或以上的可用空格，以满足一次特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在至少2只满足spfilter条件的鱼族·4星怪兽可作为效果对象。
		and Duel.IsExistingTarget(c43138260.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 发起特殊召唤目标选择提示，让tp在弹出的选择界面中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp从自己墓地的鱼族·4星怪兽中选出2张作为效果对象（取对象），并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c43138260.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置当前连锁操作信息：声明本效果会特殊召唤2只对象怪兽，供其他卡对此效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ②效果处理：取回仍相关的对象卡，若空则结束；检查主怪兽区空格数量足够且未受“不能同时特殊召唤2只以上”效果限制；随后逐只将对象怪兽表侧守备表示特殊召唤，并给每只附加不能攻击、效果无效化、不能改变表示形式、不能作为非水属性超量素材的限制；最后完成特殊召唤。
function c43138260.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁的对象卡组，并过滤出仍然与此效果有关联的卡（未离场/未被无效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 将当前对象怪兽以表侧守备表示特殊召唤（作为连续特殊召唤的一步，不检查苏生限制与召唤条件）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 这个效果特殊召唤的怪兽也不能作表示形式的变更
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		-- 把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是水属性怪兽的超量召唤不能使用。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e5:SetValue(c43138260.xyzlimit)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5)
		tc=g:GetNext()
	end
	-- 完成连续特殊召唤处理：结算所有SpecialSummonStep的特殊召唤，并触发特殊召唤成功时的各项时点。
	Duel.SpecialSummonComplete()
end
-- 定义超量素材限制条件：若超量召唤的怪兽不是水属性，则禁止使用这些特殊召唤的怪兽作为素材；若c为空则默认不限制。
function c43138260.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
