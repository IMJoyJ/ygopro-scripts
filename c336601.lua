--ムーン・ガードナー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，若对方场上有怪兽存在，以「月之守卫者」以外的自己墓地1只光属性·4星怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 此函数为「月之守卫者」注册三个效果：e1为手卡中的规则特殊召唤效果（①），e2为召唤成功时发动②效果的诱发效果，e3为e2的克隆并改为特殊召唤成功时发动②效果。
function s.initial_effect(c)
	-- ①：对方场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤的场合，若对方场上有怪兽存在，以「月之守卫者」以外的自己墓地1只光属性·4星怪兽为对象才能发动。那只怪兽加入手卡。（特殊召唤的场合由e3克隆处理）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 规则特殊召唤的条件函数：当c为nil时表示该规则召唤本身可用；否则需要满足控制者怪兽区有空位，且对方场上有2只以上怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 确认该怪兽的控制者场上是否有可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 确认对方场（以控制者视角的0号位）上存在至少2只怪兽（aux.TRUE表示不限定怪兽种类）。
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_MZONE,2,nil)
end
-- 墓地检索过滤条件：不是「月之守卫者」、等级4、光属性、怪兽卡，并且能够加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件和取目标函数：若在连锁中检查目标则验证目标合法；在发动时确认对方场上有怪兽且自己墓地存在符合条件的怪兽，并进入选目标流程。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动时需要确认对方场上有至少1只怪兽存在。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 同时需要自己墓地存在1张满足s.thfilter条件且可以成为效果对象的卡。
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择“加入手卡”卡片的提示消息（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足s.thfilter的卡作为取对象效果的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将该对象卡以CATEGORY_TOHAND分类进行处理，用于后续时点判定和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理函数：取得效果对象，若该对象仍与当前连锁相关且不受王家长眠之谷等效果影响，则将其加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果处理时选定的对象卡（这里只有1张，为其对象）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象是否仍与该连锁保持联系（未被移回或离场），且通过王家长眠之谷的过滤判定（不受王谷影响时才可处理）。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将该对象卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
