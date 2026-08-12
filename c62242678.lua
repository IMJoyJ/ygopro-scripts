--琰魔竜王 レッド・デーモン・カラミティ
-- 效果：
-- 调整2只＋调整以外的龙族·暗属性同调怪兽1只
-- ①：这张卡同调召唤时才能发动（对方不能对应这个效果的发动把卡的效果发动）。这个回合，对方不能把场上发动的效果发动。
-- ②：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ③：这张卡被对方破坏的场合，以自己墓地1只8星以下的龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c62242678.initial_effect(c)
	-- 添加同调召唤手续：调整2只＋调整以外的龙族·暗属性同调怪兽1只
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(c62242678.sfilter),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动（对方不能对应这个效果的发动把卡的效果发动）。这个回合，对方不能把场上发动的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62242678,0))  --"不能发动"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c62242678.limcon)
	e2:SetTarget(c62242678.limtg)
	e2:SetOperation(c62242678.limop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62242678,1))  --"效果伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏怪兽并送去墓地
	e3:SetCondition(aux.bdcon)
	e3:SetTarget(c62242678.damtg)
	e3:SetOperation(c62242678.damop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合，以自己墓地1只8星以下的龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62242678,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c62242678.spcon)
	e4:SetTarget(c62242678.sptg)
	e4:SetOperation(c62242678.spop)
	c:RegisterEffect(e4)
	-- 调整2只＋调整以外的龙族·暗属性同调怪兽1只
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(21142671)
	c:RegisterEffect(e5)
end
c62242678.material_type=TYPE_SYNCHRO
-- 过滤非调整同调素材：龙族·暗属性同调怪兽
function c62242678.sfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSynchroType(TYPE_SYNCHRO)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c62242678.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的靶向/发动准备：限制连锁，对方不能对应发动效果
function c62242678.limtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定连锁限制，使对方不能对应此效果的发动来发动卡的效果
	Duel.SetChainLimit(c62242678.chainlm)
end
-- 连锁限制条件：只有发动该效果的玩家可以进行连锁（即对方不能连锁）
function c62242678.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果①的运行空间：注册一个全局效果，使对方在这个回合不能把场上发动的效果发动
function c62242678.limop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡同调召唤时才能发动（对方不能对应这个效果的发动把卡的效果发动）。这个回合，对方不能把场上发动的效果发动。②：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。③：这张卡被对方破坏的场合，以自己墓地1只8星以下的龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c62242678.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该全局效果，使限制对方发动效果的限制生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的过滤函数：限制在场上发动的效果以及魔法·陷阱卡的发动
function c62242678.aclimit(e,re,tp)
	return re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果②的靶向/发动准备：获取被破坏怪兽的原本攻击力，并设置伤害操作信息
function c62242678.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息为给与对方玩家该数值的效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②的运行空间：给与对方被破坏怪兽原本攻击力数值的伤害
function c62242678.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果伤害，给与目标玩家对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果③的发动条件：这张卡被对方破坏并送去自己墓地（或除外）
function c62242678.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤特殊召唤的目标：自己墓地8星以下的龙族·暗属性同调怪兽
function c62242678.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的靶向/发动准备：选择自己墓地1只符合条件的怪兽作为对象
function c62242678.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62242678.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为对象的符合条件的怪兽
		and Duel.IsExistingTarget(c62242678.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62242678.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的运行空间：将作为对象的怪兽特殊召唤
function c62242678.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
