--グリム・リチュア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「冷酷遗式术师」以外的1只「遗式」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不用仪式怪兽不能攻击宣言。
function c38356857.initial_effect(c)
	-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c38356857.rlevel)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「冷酷遗式术师」以外的1只「遗式」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不用仪式怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,38356857)
	e2:SetTarget(c38356857.sptg)
	e2:SetOperation(c38356857.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义仪式等级辅助函数：计算这张卡作为仪式召唤解放时可提供的等级；若仪式召唤的对象是水属性怪兽，则按特殊规则提供更高的等级，以满足“水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用”的效果。
function c38356857.rlevel(e,c)
	-- 获取这张卡的等级并限制在系统安全上限内，作为仪式解放时的基础等级。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 定义特殊召唤的筛选条件：从卡组选择卡名不是本卡的「遗式」怪兽，且该怪兽可以被当前效果特殊召唤。
function c38356857.filter(c,e,tp)
	return c:IsSetCard(0x3a) and not c:IsCode(38356857) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：自己怪兽区存在可用空格，且卡组中存在至少1只符合筛选条件的「遗式」怪兽。
function c38356857.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查：自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1张满足filter条件的「遗式」怪兽（卡名不为「冷酷遗式术师」）。
		and Duel.IsExistingMatchingCard(c38356857.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本效果的操作信息设置为“从卡组特殊召唤1只怪兽”，供效果处理及相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：先进行特殊召唤，随后给自己场上所有非仪式怪兽附加直到结束阶段不能攻击宣言的自肃效果。
function c38356857.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的怪兽区域（防止发动后区域被占用）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作者显示“请选择要特殊召唤的卡”的提示，并指定选择类型为特殊召唤。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中筛选出1张符合filter条件的「遗式」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c38356857.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择到的怪兽以表侧攻击表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不用仪式怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c38356857.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，持续对发动玩家生效，限制其在结束阶段前不能进行非仪式怪兽的攻击宣言。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤条件：若怪兽不是仪式怪兽，则受到“不能攻击宣言”的限制。
function c38356857.atktg(e,c)
	return not c:IsType(TYPE_RITUAL)
end
