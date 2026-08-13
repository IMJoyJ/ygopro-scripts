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
-- 战斗破坏判定：此卡仍与战斗相关且表侧表示，其战斗对象在墓地且因战斗被破坏且为怪兽，满足‘战斗破坏怪兽送去墓地时’的发动条件。
function c53274132.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup() and bc:IsLocation(LOCATION_GRAVE)
		and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 伤害效果的目标处理：无需选择卡片对象，将对象玩家设为对方，伤害数值设为300，并登记伤害操作信息。
function c53274132.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为300，用于保存伤害数值。
	Duel.SetTargetParam(300)
	-- 登记操作信息：本次效果将造成伤害，对象为对方玩家（1-tp），数值为300；因为没有对象卡，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 伤害效果处理：取得连锁中记录的对象玩家和伤害数值，对对方造成对应的效果伤害。
function c53274132.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中存储的对象玩家和对象参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对p玩家造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 作为发动代价：检查本回合此卡尚未进行过攻击宣言；随后给自己附加‘不能攻击’的誓约效果，持续到回合结束，且该效果不能被无效。
function c53274132.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 特殊召唤候选过滤：等级4以下、卡名属于‘链’系列（0x25）、不是「链·修理工」自身、并且可以被当前效果特殊召唤（不检查召唤条件，检查苏生限制）。
function c53274132.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x25) and not c:IsCode(53274132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标处理：连锁确认时检查候选卡是否在墓地且属于自己并满足过滤条件；发动时需要自己场上有可用怪兽区空格且墓地存在满足条件的对象。
function c53274132.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53274132.spfilter(chkc,e,tp) end
	-- 效果发动条件：自己场上存在可用的主要怪兽区空格（可用空格数大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在满足特殊召唤条件的怪兽，才能作为对象发动。
		and Duel.IsExistingTarget(c53274132.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示‘请选择要特殊召唤的卡’的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c53274132.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果为特殊召唤，对象为已选择的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：获取效果对象怪兽，若其仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c53274132.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件，不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
