--No.99 希望皇ホープドラグナー
-- 效果：
-- 12星怪兽×3只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡2个超量素材取除才能发动（这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤，其他的自己怪兽不能直接攻击）。把1只「No.1」～「No.100」其中任意种的「No.」怪兽当作超量召唤从额外卡组特殊召唤。
-- ②：对方怪兽的攻击宣言时才能发动。那只对方怪兽的攻击力变成0。
function c95134948.initial_effect(c)
	-- 设置该卡常规超量召唤手续为12星怪兽3只以上
	aux.AddXyzProcedure(c,nil,12,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡2个超量素材取除才能发动（这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤，其他的自己怪兽不能直接攻击）。把1只「No.1」～「No.100」其中任意种的「No.」怪兽当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95134948,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,95134948)
	e1:SetCost(c95134948.spcost)
	e1:SetTarget(c95134948.sptg)
	e1:SetOperation(c95134948.spop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时才能发动。那只对方怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95134948,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,95134949)
	e2:SetCondition(c95134948.atkcon)
	e2:SetOperation(c95134948.atkop)
	c:RegisterEffect(e2)
	-- 注册自定义活动计数器，用于检测本回合是否从额外卡组特殊召唤过超量怪兽以外的怪兽
	Duel.AddCustomActivityCounter(95134948,ACTIVITY_SPSUMMON,c95134948.counterfilter)
	if not c95134948.global_check then
		c95134948.global_check=true
		-- 其他的自己怪兽不能直接攻击
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c95134948.dacheck)
		-- 注册全局效果，用于记录怪兽的直接攻击宣言情况
		Duel.RegisterEffect(ge1,0)
	end
end
-- 将该卡的卡号与No.编号99进行关联
aux.xyz_number[95134948]=99
-- 过滤函数：不是从额外卡组特殊召唤，或者是超量怪兽
function c95134948.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_XYZ)
end
-- 攻击宣言时的全局检查函数，用于记录进行直接攻击的怪兽及玩家
function c95134948.dacheck(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p=tc:GetControler()
	-- 若存在攻击对象（非直接攻击），则不进行处理
	if Duel.GetAttackTarget()~=nil then return end
	if tc:GetFlagEffect(95134948)==0 then
		tc:RegisterFlagEffect(95134948,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 检查该玩家本回合是否是第一次有怪兽进行直接攻击
		if Duel.GetFlagEffect(p,95134948)==0 then
			-- 为玩家注册Flag，表示本回合已有1只怪兽进行了直接攻击
			Duel.RegisterFlagEffect(p,95134948,RESET_PHASE+PHASE_END,0,1)
		else
			-- 为玩家注册Flag，表示本回合已有其他怪兽进行了直接攻击
			Duel.RegisterFlagEffect(p,95134949,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 效果①的发动代价与限制条件检测函数
function c95134948.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST)
		-- 检查本回合是否未从额外卡组特殊召唤过超量怪兽以外的怪兽
		and Duel.GetCustomActivityCount(95134948,tp,ACTIVITY_SPSUMMON)==0
		-- 检查本回合是否有其他怪兽进行过直接攻击
		and Duel.GetFlagEffect(tp,95134949)==0
		-- 检查是否没有怪兽直接攻击过，或者唯一直接攻击过的是这张卡自身
		and (Duel.GetFlagEffect(tp,95134948)==0 or c:GetFlagEffect(95134948)~=0) end
	-- 这个效果发动的回合，自己不是超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95134948.splimit)
	-- 注册限制玩家从额外卡组特殊召唤非超量怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 其他的自己怪兽不能直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c95134948.ftarget)
	e2:SetLabel(c:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制其他自己怪兽不能直接攻击的效果
	Duel.RegisterEffect(e2,tp)
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 限制特召的过滤函数，使玩家不能从额外卡组特殊召唤非超量怪兽
function c95134948.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 限制直接攻击的过滤函数，使除这张卡以外的怪兽不能直接攻击
function c95134948.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 过滤额外卡组中满足条件的「No.1」～「No.100」的「No.」怪兽
function c95134948.spfilter(c,e,tp)
	-- 获取卡片的No.编号
	local no=aux.GetXyzNumber(c)
	return no and no>=1 and no<=100 and c:IsSetCard(0x48)
		-- 检查该卡是否可以当作超量召唤特殊召唤，且额外怪兽区域有可用空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备与合法性检测函数
function c95134948.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为超量素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「No.」怪兽
		and Duel.IsExistingMatchingCard(c95134948.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理函数（从额外卡组特殊召唤「No.」怪兽）
function c95134948.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查必须作为超量素材的卡片限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「No.」怪兽
	local tc=Duel.SelectMatchingCard(tp,c95134948.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽以超量召唤的形式表侧表示特殊召唤，若成功则进行后续处理
		if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
-- 效果②的发动条件检测函数
function c95134948.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的攻击宣言，且攻击怪兽的攻击力大于0
	return tp~=Duel.GetTurnPlayer() and aux.nzatk(Duel.GetAttacker())
end
-- 效果②的效果处理函数（将攻击怪兽的攻击力变成0）
function c95134948.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 那只对方怪兽的攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
