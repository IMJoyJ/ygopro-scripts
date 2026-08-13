--ブリンクアウト
-- 效果：
-- ①：以场上1只连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把已作为那只怪兽的连接素材送去自己墓地的1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：创建①效果，设置其类别为回额外卡组+特殊召唤+从墓地特殊召唤，类型为魔法卡发动，属性为取对象，发动时机为自由时点，绑定目标选择函数与效果处理函数，最后将效果注册给卡片。
function s.initial_effect(c)
	-- ①：以场上1只连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把已作为那只怪兽的连接素材送去自己墓地的1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义效果对象筛选条件：对象必须是表侧表示的连接怪兽，并且能够返回额外卡组。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 目标选择阶段：处理连锁时校验对象是否位于主要怪兽区且满足筛选条件；发动时检查场上是否存在合法对象；存在则提示玩家选择1只连接怪兽，将其设为效果对象，并设置返回额外卡组的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 发动合法性检查：若场上不存在满足条件的连接怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方主要怪兽区选择1只满足条件的连接怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：声明本次效果会将1只对象卡返回额外卡组，供相关卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 定义连接素材筛选条件：该怪兽的控制者是自己、位于墓地、是作为那只连接怪兽的连接素材被送去墓地（原因包含连接召唤素材，原因卡为返回额外卡组的连接怪兽），且可以被效果特殊召唤。
function s.mgfilter(c,e,tp,link)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x10000008)==0x10000008 and c:GetReasonCard()==link
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段：取得对象连接怪兽，若对象已离场或变成里侧表示则效果不适用；否则取得其素材和召唤方式。若对象成功返回额外卡组，则从素材中筛选出符合条件的怪兽，询问玩家是否特殊召唤；选择“是”后提示选择1只，中断效果处理并将该怪兽特殊召唤到自己场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡（连接怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local sumtype=tc:GetSummonType()
	-- 将对象连接怪兽返回持有者的额外卡组（置于卡组顶端），若成功返回则继续后续处理。
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 then
		-- 对连接素材组应用王家长眠之谷的过滤，再按s.mgfilter筛选出自己墓地中满足条件的连接素材。
		mg=mg:Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc)
		if sumtype==SUMMON_TYPE_LINK and tc:IsLocation(LOCATION_EXTRA)
			-- 追加判断：该怪兽是以连接召唤方式出场、且已经回到额外卡组，同时自己主要怪兽区有空位，并且存在可特殊召唤的素材。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>0
			-- 询问玩家是否发动“那之后”的特殊召唤效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 向玩家显示选择提示：请选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=mg:Select(tp,1,1,nil)
			-- 中断当前效果处理，使后续特殊召唤与此前的返回额外卡组处理不在同一时点，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的1只素材怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
