--RR－ワイズ・ストリクス
-- 效果：
-- 鸟兽族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，效果无效化。
-- ②：自己的「急袭猛禽」超量怪兽的效果发动的场合发动。从卡组把1张「升阶魔法」魔法卡在自己场上盖放。把速攻魔法卡盖放的场合，那张卡在盖放的回合也能发动。
function c36429703.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只鸟兽族·暗属性怪兽作为连接素材。
	aux.AddLinkProcedure(c,c36429703.matfilter,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36429703,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,36429703)
	e1:SetCondition(c36429703.spcon)
	e1:SetTarget(c36429703.sptg)
	e1:SetOperation(c36429703.spop)
	c:RegisterEffect(e1)
	-- ②：自己的「急袭猛禽」超量怪兽的效果发动的场合发动。从卡组把1张「升阶魔法」魔法卡在自己场上盖放。把速攻魔法卡盖放的场合，那张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36429703,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,36429704)
	e3:SetCondition(c36429703.setcon)
	e3:SetOperation(c36429703.setop)
	c:RegisterEffect(e3)
end
-- 判定连接素材是否满足条件：鸟兽族且暗属性。
function c36429703.matfilter(c)
	return c:IsLinkRace(RACE_WINDBEAST) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- 效果发动条件：这张卡是连接召唤成功（召唤类型为连接召唤）。
function c36429703.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选卡组中符合条件的怪兽：4星、鸟兽族、暗属性，且可以表侧守备表示特殊召唤。
function c36429703.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的合法性检查：自己场上有可用怪兽区空格，且卡组中存在符合spfilter条件的怪兽。
function c36429703.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合spfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c36429703.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次操作信息登记为从卡组特殊召唤1只怪兽，用于后续时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽以表侧守备表示特殊召唤，并给它附加效果无效化、效果无效、不能作为连接素材的负面效果。
function c36429703.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认场上仍有可用怪兽区空格，否则直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足spfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c36429703.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试将选择的怪兽以表侧守备表示特殊召唤，成功后继续附加负面效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽不能作为连接素材。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤手续，使步骤式特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：自己场上的「急袭猛禽」超量怪兽的效果发动并进入连锁时。
function c36429703.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_XYZ) and rc:IsSetCard(0xba) and rc:IsControler(tp)
end
-- 筛选卡组中满足条件的卡片：属于「升阶魔法」字段的魔法卡且可以盖放。
function c36429703.setfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果处理：从卡组选择1张「升阶魔法」魔法卡盖放到自己场上；若盖放的是速攻魔法，则追加“盖放的回合也能发动”的效果。
function c36429703.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足setfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c36429703.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡片盖放到自己场上，若成功盖放则继续处理速攻魔法追加效果。
	if tc and Duel.SSet(tp,tc)~=0 then
		if tc:IsType(TYPE_QUICKPLAY) then
			-- 把速攻魔法卡盖放的场合，那张卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(36429703,2))  --"适用「急袭猛禽-智慧林鸮」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
