--八雲断巳剣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己墓地有「巳剑」仪式魔法卡存在的场合，把原本卡名是「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的自己场上的怪兽各1只解放才能发动。对方必须从自身的手卡·额外卡组·场上·墓地把合计8张卡除外。
local s,id,o=GetID()
-- 定义该卡的初始化函数：将效果e1注册给卡片，e1为魔法卡发动、自由时点、除外分类、誓约一回合一次，并指定条件/代价/目标/处理函数。
function s.initial_effect(c)
	-- 将该卡效果文本中提到的三只剑怪兽的卡号登记到代码列表，用于规则上视为记载那些卡名。
	aux.AddCodeList(c,13332685,19899073,55397172)
	-- 创建并注册效果e1：设置类别为除外，类型为魔法发动，发动时点为自由时点，誓约1回合1次，并绑定条件、代价、目标、处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 为三只原本卡名的怪兽各生成一个判定函数，用于后续检查是否凑齐这3只不同名的解放素材。
s.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{13332685,19899073,55397172})
-- 定义筛选函数：判断一张卡是否满足「巳剑」仪式魔法卡（字段0x1c3、仪式、魔法卡）。
function s.cfilter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL)
end
-- 定义发动条件：自己墓地存在至少1张满足条件的「巳剑」仪式魔法卡。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张符合条件的「巳剑」仪式魔法卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义解放素材筛选：怪兽的原本卡名必须是三把剑之一，且控制者为发动者或表侧表示（确保可作为解放对象）。
function s.rlfilter(c,tp)
	return c:IsOriginalCodeRule(13332685,19899073,55397172) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义代价函数：从可解放的怪兽中凑齐三种不同原本卡名的剑怪兽，选择后作为发动代价解放。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前玩家可解放的怪兽组，并过滤出原本卡名属于三把剑之一的候选怪兽。
	local g=Duel.GetReleaseGroup(tp,false):Filter(s.rlfilter,c,tp)
	if chk==0 then return g:CheckSubGroupEach(s.spchecks) end
	-- 弹出选择提示，让玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,s.spchecks,false)
	-- 使用额外解放次数（如暗影敌托邦等代替解放效果），并消耗对应效果的使用次数。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选择的怪兽作为代价解放。
	Duel.Release(rg,REASON_COST)
end
-- 定义效果发动目标：获取对方场上·手卡·墓地·额外卡组的全部卡，检查对方能否除外且存在至少8张可除外的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方所有区域（场上、手卡、墓地、额外卡组）的卡片组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA)
	-- 发动时检查对方玩家是否允许除外卡片，若不允许则不能发动。
	if chk==0 then return Duel.IsPlayerCanRemove(1-tp)
		and g:IsExists(Card.IsAbleToRemove,8,nil,1-tp,POS_FACEUP,REASON_RULE) end
	-- 设置效果处理时的操作信息：除外分类，处理对象为对方的手卡·额外·场上·墓地区域。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 定义效果处理：对方存在可除外的卡时，由对方从可除外的卡中选8张，表侧表示除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再次确认对方玩家能否除外卡，若不能则直接结束处理。
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	-- 获取对方场上·手卡·墓地·额外卡组中所有能够被除外的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,nil,1-tp,POS_FACEUP,REASON_RULE)
	if g:GetCount()>7 then
		-- 弹出选择提示，令对方玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(1-tp,8,8,nil)
		if sg:GetCount()>7 then
			-- 将对方选择的8张卡以表侧表示除外（规则除外）。
			Duel.Remove(sg,POS_FACEUP,REASON_RULE,1-tp)
		end
	end
end
