--C・リペアラー
-- 效果：
-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分300分伤害。1回合1次，可以把自己墓地存在的「链·修理工」以外的1只名字带有「链」的4星以下的怪兽特殊召唤。这个效果发动的回合这张卡不能攻击。
function c53274132.initial_effect(c)
	-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分300分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53274132,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c53274132.damcon)
	e1:SetTarget(c53274132.damtg)
	e1:SetOperation(c53274132.damop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己墓地存在的「链·修理工」以外的1只名字带有「链」的4星以下的怪兽特殊召唤。这个效果发动的回合这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53274132,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c53274132.spcost)
	e2:SetTarget(c53274132.sptg)
	e2:SetOperation(c53274132.spop)
	c:RegisterEffect(e2)
end
-- 判断本次战斗破坏是否有效，即己方怪兽参与战斗且对方怪兽在墓地，且为战斗破坏且为怪兽。
function c53274132.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup() and bc:IsLocation(LOCATION_GRAVE)
		and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 设置连锁处理时的目标玩家为对方玩家，目标参数为300，操作信息为造成300点伤害。
function c53274132.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的目标参数设置为300。
	Duel.SetTargetParam(300)
	-- 设置当前处理的连锁的操作信息为造成300点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行伤害效果，对目标玩家造成300点伤害。
function c53274132.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 设置此卡在本回合不能攻击的效果。
function c53274132.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 使此卡在本回合不能攻击，该效果为誓约效果且无法无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 筛选满足条件的墓地怪兽：等级4以下、名字带有「链」、不是此卡本身、可以特殊召唤。
function c53274132.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x25) and not c:IsCode(53274132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件，即场上存在可特殊召唤的墓地目标怪兽。
function c53274132.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53274132.spfilter(chkc,e,tp) end
	-- 判断己方场上的可用怪兽区域数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地中是否存在符合条件的目标怪兽。
		and Duel.IsExistingTarget(c53274132.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地中选择一个符合条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c53274132.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁的操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，将目标怪兽特殊召唤到场上。
function c53274132.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以指定方式特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
