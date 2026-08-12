--葬世の神 デーヴァリーム
-- 效果：
-- 这张卡不能通常召唤。「葬世之神 德瓦里姆」1回合1次在把攻击力或守备力是2500的自己墓地2只怪兽除外的场合才能从墓地特殊召唤。
-- ①：这张卡特殊召唤的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。
-- ②：对方场上的怪兽的攻击力只在战斗阶段内下降2500。
local s,id,o=GetID()
-- 初始化卡片效果：注册不可通常召唤的特殊召唤条件（e0）、从墓地除外2只怪兽特殊召唤的规则手续（e1）、特殊召唤成功时让对方场上·墓地的卡回手卡的诱发效果（e2）以及战斗阶段内对方怪兽攻击力下降2500的永续效果（e3）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 「葬世之神 德瓦里姆」1回合1次在把攻击力或守备力是2500的自己墓地2只怪兽除外的场合才能从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以最多有攻击力或守备力是2500的自己的除外状态的怪兽数量的对方的场上·墓地的卡为对象才能发动。那些卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方场上的怪兽的攻击力只在战斗阶段内下降2500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(-2500)
	c:RegisterEffect(e3)
end
-- 特殊召唤代价的过滤函数：筛选攻击力或守备力是2500且可以作为代价除外的怪兽
function s.sprfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的发动条件：自己主要怪兽区有空位，且墓地存在至少2只满足条件的可作为代价除外的怪兽（不含这张卡本身）
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己的主要怪兽区是否还有可使用的空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少2只攻击力或守备力是2500、可以作为代价除外的怪兽（除外这张卡自身）
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler())
end
-- 特殊召唤手续的对象选择：从自己墓地筛选满足条件的怪兽，提示后由玩家选择2只要除外的怪兽并保存到标签对象中，可取消（取消则手续失败）
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 从自己墓地检索全部攻击力或守备力是2500且可以作为代价除外的怪兽（不含这张卡自身）
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 向玩家显示「请选择要除外的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：取出之前选好的2只怪兽，将它们以表侧表示除外作为特殊召唤的代价，然后释放该卡组
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选好的2只怪兽以表侧表示除外，作为这次特殊召唤的代价
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 计算数量用的过滤函数：筛选攻击力或守备力是2500且表侧表示除外的怪兽
function s.cfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsFaceupEx()
end
-- ①效果的对象选择：统计自己除外状态的攻击力或守备力是2500的怪兽数量ct，确认存在可回手卡的对方场上·墓地的卡后，以最多ct张对方场上·墓地的卡为对象（优先选场上的卡），并设置回手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 统计自己除外状态的攻击力或守备力是2500的表侧表示怪兽的数量，作为可取对象数量的上限
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,0,nil)
	-- 发动条件检查：除外状态的符合条件的怪兽数量大于0，且对方场上·墓地存在至少1张可以回到手卡的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 向玩家显示「请选择要返回手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以1到ct张对方场上·墓地的可以回到手卡的卡为对象，优先从场上选择
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	-- 设置回手卡效果的操作信息，供王家长眠之谷等效果的连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果的处理：取得与本连锁相关的对象卡，过滤掉受王家长眠之谷影响的卡，将剩余的卡全部回到持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁相关联的对象卡，并用王家长眠之谷过滤器剔除受影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将那些卡以效果处理的方式回到持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的适用条件：只有当前处于战斗阶段时才生效
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段内
	return Duel.IsBattlePhase()
end
