--武神姫－アハシマ
-- 效果：
-- 相同等级的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。这张卡不能作为连接素材。
-- ①：这张卡连接召唤成功的场合才能发动。相同等级的怪兽从手卡以及自己墓地各选1只效果无效特殊召唤，只用那2只为素材把1只超量怪兽超量召唤。
-- ②：这张卡所连接区的超量怪兽把超量素材取除来让效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c71095768.initial_effect(c)
	-- 开启全局的拔除超量素材事件监听（用于检测超量素材被取除的时点）。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 添加连接召唤手续：相同等级的怪兽2只。
	aux.AddLinkProcedure(c,c71095768.mfilter,2,2,c71095768.lcheck)
	c:EnableReviveLimit()
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合才能发动。相同等级的怪兽从手卡以及自己墓地各选1只效果无效特殊召唤，只用那2只为素材把1只超量怪兽超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71095768,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,71095768)
	e2:SetCondition(c71095768.spcon)
	e2:SetTarget(c71095768.sptg)
	e2:SetOperation(c71095768.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡所连接区的超量怪兽把超量素材取除来让效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(71095768,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1,71095769)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c71095768.descon)
	e4:SetTarget(c71095768.destg)
	e4:SetOperation(c71095768.desop)
	c:RegisterEffect(e4)
	if not c71095768.global_check then
		c71095768.global_check=true
		c71095768[0]=nil
		c71095768[1]=nil
		c71095768[2]=nil
		-- ②：这张卡所连接区的超量怪兽把超量素材取除来让效果发动的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(c71095768.checkop)
		-- 注册全局监听效果，用于记录超量素材被取除时的连锁信息。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 超量素材被取除时的事件处理函数，记录当前连锁ID、发动位置以及发动怪兽所在的区域序号。
function c71095768.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号。
	local cid=Duel.GetCurrentChain()
	if cid>0 and (r&REASON_COST)>0 then
		-- 记录当前连锁的唯一标识ID。
		c71095768[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
		-- 记录当前连锁发生位置。
		c71095768[1]=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
		-- 获取当前连锁发生位置的序号。
		local seq=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_SEQUENCE)
		-- 获取当前连锁触发的效果。
		local te=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc:IsRelateToEffect(te) then
			if tc:IsControler(1) then seq=seq+16 end
		else
			if tc:IsPreviousControler(1) then seq=seq+16 end
		end
		c71095768[2]=seq
	end
end
-- 过滤连接素材：等级1以上的怪兽。
function c71095768.mfilter(c)
	return c:IsLevelAbove(1)
end
-- 检查连接素材：所有素材怪兽的等级必须相同。
function c71095768.lcheck(g,lc)
	return g:GetClassCount(Card.GetLevel)==1
end
-- 检查效果①的发动条件：这张卡是连接召唤成功的。
function c71095768.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤手卡或墓地中可以特殊召唤的等级1以上的怪兽。
function c71095768.spfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查选出的2只怪兽是否分别来自手卡和墓地、等级是否相同，且额外卡组是否存在能用这2只怪兽作为素材超量召唤的怪兽。
function c71095768.fselect(g,tp)
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and g:GetClassCount(Card.GetLevel)==1
		-- 检查额外卡组是否存在能以选出的怪兽组作为素材进行超量召唤的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,g,2,2)
end
-- 效果①的发动准备：检查玩家能否特召2只怪兽、是否有足够的怪兽区域，以及是否存在满足条件的特召与超量召唤组合。
function c71095768.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡和墓地中满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c71095768.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 检查玩家是否能进行2次特殊召唤。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的怪兽区域是否有2个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:CheckSubGroup(c71095768.fselect,2,2,tp) end
	-- 设置特殊召唤的操作信息：从手卡·墓地特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理：从手卡和墓地各特召1只同等级怪兽并无效效果，然后用这2只怪兽为素材进行超量召唤。
function c71095768.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡和墓地中满足特召条件且不受王家长眠之谷影响的怪兽组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c71095768.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c71095768.fselect,false,2,2,tp)
	if sg and sg:GetCount()==2 then
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 放入特殊召唤的第一只怪兽（准备特殊召唤）。
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 放入特殊召唤的第二只怪兽（准备特殊召唤）。
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=e1:Clone()
		tc2:RegisterEffect(e2)
		-- 效果无效
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e3)
		local e4=e3:Clone()
		tc2:RegisterEffect(e4)
		-- 完成上述两只怪兽的特殊召唤。
		Duel.SpecialSummonComplete()
		-- 立刻刷新场地信息。
		Duel.AdjustAll()
		if sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
		-- 获取额外卡组中能以这2只怪兽为素材进行超量召唤的怪兽组。
		local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,sg,2,2)
		if xyzg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 用选出的2只怪兽作为素材进行超量召唤。
			Duel.XyzSummon(tp,xyz,sg)
		end
	end
end
-- 效果②的发动条件：这张卡所连接区的超量怪兽把超量素材取除来让效果发动。
function c71095768.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发效果的连锁ID是否与之前记录的取除超量素材的连锁ID一致。
	if not (Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==c71095768[0]
		and c71095768[1]==LOCATION_MZONE and re:IsActiveType(TYPE_XYZ)) then return false end
	local c=e:GetHandler()
	local zone=(c:GetLinkedZone(0) & 0x7f) | ((c:GetLinkedZone(1) & 0x7f)<<0x10)
	local seq=c71095768[2]
	return seq and bit.extract(zone,seq)~=0
end
-- 效果②的发动准备：选择对方场上1张魔法·陷阱卡作为对象。
function c71095768.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置破坏的操作信息：破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏作为对象的卡。
function c71095768.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
