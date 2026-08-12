--剣闘獣ゲオルディアス
-- 效果：
-- 「剑斗兽 斯巴达克斯」＋名字带有「剑斗兽」的怪兽
-- 把自己场上存在的上记的卡回到卡组的场合才能从融合卡组特殊召唤（不需要「融合」魔法卡）。这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的守备力数值的伤害。这张卡进行战斗的战斗阶段结束时可以让这张卡回到融合卡组，从卡组把「剑斗兽 斯巴达克斯」以外的2只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c90957527.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为卡名含有「剑斗兽 斯巴达克斯」（79580323）的怪兽和1只「剑斗兽」怪兽
	aux.AddFusionProcCodeFun(c,79580323,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),1,true,true)
	-- 添加接触融合召唤手续，将自己场上的素材送回卡组来从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,c90957527.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 把自己场上存在的上记的卡回到卡组的场合才能从融合卡组特殊召唤（不需要「融合」魔法卡）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c90957527.splimit)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的守备力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90957527,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c90957527.damcon)
	e3:SetTarget(c90957527.damtg)
	e3:SetOperation(c90957527.damop)
	c:RegisterEffect(e3)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到融合卡组，从卡组把「剑斗兽 斯巴达克斯」以外的2只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90957527,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c90957527.spcon)
	e4:SetCost(c90957527.spcost)
	e4:SetTarget(c90957527.sptg)
	e4:SetOperation(c90957527.spop)
	c:RegisterEffect(e4)
end
-- 限制该卡从额外卡组特殊召唤时必须使用其自身规定的特殊召唤程序
function c90957527.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 过滤接触融合素材：场上卡名为「剑斗兽 斯巴达克斯」或属于「剑斗兽」系列的怪兽，且可以回到卡组
function c90957527.cfilter(c)
	return (c:IsFusionCode(79580323) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 战斗破坏伤害效果的发动条件：自身在战斗中存活，且被破坏的怪兽作为怪兽卡存在于墓地，并记录该怪兽的守备力
function c90957527.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（防守方）
	local d=Duel.GetAttackTarget()
	if c==a then
		e:SetLabel(d:GetDefense())
		return c:IsRelateToBattle() and d:IsLocation(LOCATION_GRAVE) and d:IsType(TYPE_MONSTER)
	else
		e:SetLabel(a:GetDefense())
		return c:IsRelateToBattle() and a:IsLocation(LOCATION_GRAVE) and a:IsType(TYPE_MONSTER)
	end
end
-- 战斗破坏伤害效果的靶向处理：设置对方玩家为效果对象，并注册伤害数值
function c90957527.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local d=e:GetLabel()
	-- 设置对方玩家为受到伤害的对象
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为被破坏怪兽的守备力
	Duel.SetTargetParam(d)
	-- 注册连锁处理信息：对对方玩家造成等同于被破坏怪兽守备力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
-- 战斗破坏伤害效果的执行：获取目标玩家和伤害数值，并给予伤害
function c90957527.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果对目标玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：该卡在本次战斗阶段进行过战斗
function c90957527.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的发动代价：将自身送回额外卡组
function c90957527.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 作为发动代价，将自身送回额外卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「剑斗兽」怪兽（不含「剑斗兽 斯巴达克斯」）
function c90957527.filter(c,e,tp)
	return not c:IsCode(79580323) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向处理：检查怪兽区域空位数（考虑自身离场释放的格子）和「青眼精灵龙」的限制，并注册特殊召唤2只怪兽的信息
function c90957527.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上怪兽区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查卡组中是否存在至少2只满足特殊召唤条件的「剑斗兽」怪兽
			and Duel.IsExistingMatchingCard(c90957527.filter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 注册连锁处理信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行：从卡组选择2只满足条件的「剑斗兽」怪兽，依次进行特殊召唤
function c90957527.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的怪兽区域空位数不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足特殊召唤条件的「剑斗兽」怪兽
	local g=Duel.GetMatchingGroup(c90957527.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将选中的第一只怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将选中的第二只怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成分步特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
