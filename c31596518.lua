--冥帝王エイドス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「帝王」魔法·陷阱卡或者1只攻击力2800/守备力1000的怪兽加入手卡。
-- ②：宣言1个属性才能发动。场上1只怪兽的属性变成宣言的属性。
-- ③：这张卡在墓地存在的状态，自己把攻击力2400以上而守备力1000的怪兽上级召唤的场合才能发动。这张卡加入手卡或特殊召唤。
local s,id,o=GetID()
-- 创建并注册冥帝王哀多斯的全部效果：①召唤/特殊召唤成功时检索「帝王」魔法陷阱卡或指定数值怪兽；②起动效果宣言属性并改变场上怪兽属性；③墓地存在时自己上级召唤指定怪兽后可回收或特殊召唤自身。
function s.initial_effect(c)
	-- 这张卡召唤的场合才能发动。从自己的卡组·墓地把1张「帝王」魔法·陷阱卡或者1只攻击力2800/守备力1000的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：宣言1个属性才能发动。场上1只怪兽的属性变成宣言的属性。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己把攻击力2400以上而守备力1000的怪兽上级召唤的场合才能发动。这张卡加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 筛选卡组·墓地中能够加入手卡的卡：满足「帝王」魔法·陷阱卡，或攻击力2800且守备力1000的怪兽。
function s.filter(c)
	return (c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsType(TYPE_MONSTER) and c:IsAttack(2800) and c:IsDefense(1000))
		and c:IsAbleToHand()
end
-- ①效果的发动条件判定与操作信息设置：检查自己卡组·墓地是否存在可检索目标，并设置本轮连锁将执行‘加入手卡’检索。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若自己的卡组·墓地中不存在满足s.filter的卡，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果处理将从卡组·墓地取1张卡加入手卡（分类为回手牌），供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从自己的卡组·墓地把1张满足条件的「帝王」魔法·陷阱卡或指定攻击力/守备力怪兽加入手卡，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张满足s.filter且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件判定与属性宣言：收集场上表侧表示怪兽当前没有的属性，若存在可选属性则要求宣言1个属性，并将宣言属性存入效果标签。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=0
	-- 取得场上（双方主要怪兽区）所有表侧表示的怪兽。
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历这些表侧怪兽，按位汇总当前场上尚未出现的属性，得到可宣言的属性集合。
	for tc in aux.Next(mg) do
		att=att|(ATTRIBUTE_ALL&~tc:GetAttribute())
	end
	if chk==0 then return att>0 end
	-- 显示属性宣言提示：‘请选择要宣言的属性’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可宣言属性中选择1个属性，并作为标签值保存到效果e中。
	local aatt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(aatt)
end
-- ②效果处理：将场上1只表侧表示怪兽的属性变为宣言的属性。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	-- 显示选择对象提示：‘请选择效果的对象’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示且当前属性不等于所宣言属性的怪兽作为效果对象。
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,aux.NOT(Card.IsAttribute)),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,att)
	if g:GetCount()>0 then
		-- 为选中的怪兽播放被选为对象的动画并记录选对象信息。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 场上1只怪兽的属性变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：自己上级召唤了攻击力2400以上且守备力1000的怪兽，且本卡在墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonPlayer(tp) and tc:IsSummonType(SUMMON_TYPE_ADVANCE)
		and tc:IsAttackAbove(2400) and tc:IsDefense(1000)
end
-- ③效果的发动条件判定与操作信息设置：确认本卡可加入手卡或可特殊召唤，并同时设置回手牌与特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：本卡能够加入手卡，或自己场上有空位且能够特殊召唤，二者满足其一才可发动。
	if chk==0 then return c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果可能将墓地的本卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：本次效果可能将墓地的本卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：从‘加入手卡’和‘特殊召唤’中选择一项执行，并分别进行对应处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前校验：本卡仍与当前连锁相关（未被无效/移动）且不受王家长眠之谷影响，否则结束处理。
	if not c:IsRelateToChain() or not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 计算特殊召唤选项是否可用：自己主要怪兽区有空位，且本卡可以特殊召唤。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 让玩家在可用的选项中选择：加入手卡（返回1）或特殊召唤（返回2）。
	local op=aux.SelectFromOptions(tp,{b1,1190,1},{b2,1152,2})
	if op==1 then
		-- 选择加入手卡时，将本卡加入其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	elseif op==2 then
		-- 选择特殊召唤时，将本卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
