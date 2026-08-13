--エクストラ・ヴェーラー
-- 效果：
-- 对方把怪兽特殊召唤时，可以从手卡把这张卡特殊召唤。这个效果特殊召唤的回合，对方的卡的效果发生的对自己的效果伤害由对方代受。
function c32391566.initial_effect(c)
	-- 对方把怪兽特殊召唤时，可以从手卡把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32391566,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32391566.spcon)
	e1:SetTarget(c32391566.sptg)
	e1:SetOperation(c32391566.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断事件中的怪兽是否是指定玩家（此处传入对方）所特殊召唤的。
function c32391566.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 触发条件：存在对方玩家特殊召唤的怪兽，即“对方把怪兽特殊召唤时”。
function c32391566.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32391566.cfilter,1,nil,1-tp)
end
-- 发动时点合法性检查：自己主要怪兽区有空位，且手牌中的此卡能够被特殊召唤。
function c32391566.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空格（大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：本效果将特殊召唤此卡（分类为特殊召唤，数量为1），供相关时点与连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果关联则将其特殊召唤；成功后以己方玩家为对象，注册一个本回合内有效的伤害反射效果，使对方的卡造成的效果伤害由对方代受。
function c32391566.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡仍与发动效果关联，并且特殊召唤成功（返回值不为0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的回合，对方的卡的效果发生的对自己的效果伤害由对方代受。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_REFLECT_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c32391566.val)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将上述伤害反射效果注册并适用于己方玩家，使其在本回合内生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 反射效果的判定函数：当伤害原因包含效果伤害（REASON_EFFECT）时返回真，即只对效果伤害进行反射。
function c32391566.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
