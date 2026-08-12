--カプセル・モンスター・チェス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：双方玩家在自身的主要阶段以自身墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在自身的魔法与陷阱区域表侧表示放置。
-- ②：双方玩家在自身的结束阶段把自身场上1张表侧表示的怪兽卡送去墓地才能发动。原本等级比那只怪兽高1～3星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册场地魔法通用的可自由时点发动的空效果e1；注册双方主要阶段可用的起动效果e2（取对象，把墓地怪兽当作永续魔法卡放置，1回合1次）；注册双方结束阶段的诱发选发效果e3（把怪兽送去墓地从卡组特殊召唤，1回合1次）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在自身的主要阶段以自身墓地1只怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"放置怪兽"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ②：双方玩家在自身的结束阶段把自身场上1张表侧表示的怪兽卡送去墓地才能发动。原本等级比那只怪兽高1～3星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义对象过滤函数：可放置的魔法与陷阱区域空格判定（控制权与持有者不一致时用控制权变更判定），并筛选本身是怪兽、未被禁止在场上使用、不违反同名卡限制且处于表侧表示状态的卡
function s.filter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then r=LOCATION_REASON_CONTROL end
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
		-- 并且该卡处于表侧表示状态，且该卡持有者的魔法与陷阱区域有可用的空格
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- ①效果的目标函数：确认对象选择的合法性；发动时检查自己墓地是否存在可作为对象的怪兽；提示并选取对象，同时声明该连锁会让卡离开墓地的操作信息
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	-- 发动条件检查：以自己墓地1只满足条件的怪兽为对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：声明该连锁处理时会让对象卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ①效果的处理函数：取得对象怪兽，确认其仍与连锁关联、不受效果免疫影响且不受王家长眠之谷影响，将其表侧表示移动到持有者的魔法与陷阱区域，再赋予其不可无效化的、离开场地时解除的类型变更效果，使其当作永续魔法卡使用
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 且该对象不受王家长眠之谷的影响
		and aux.NecroValleyFilter()(tc)
		-- 并且把对象怪兽表侧表示移动到持有者自身的魔法与陷阱区域
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用在自身的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件函数：仅在回合玩家自己的结束阶段可以发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅当当前回合玩家是发动效果的玩家时才能发动（双方玩家在自身的结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 定义代价过滤函数：筛选场上表侧表示的原本种类是怪兽、可作为代价送去墓地、原本有等级、卡组存在可特殊召唤的对应怪兽且该卡离场后有可用怪兽区域的卡
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
		-- 并且该卡原本有等级，且卡组中存在满足特殊召唤条件的对应怪兽
		and c:GetOriginalLevel()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
		-- 并且该卡离场后自己场上还有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤对象过滤函数：筛选原本等级比代价怪兽高1～3星、原本种族·属性与代价怪兽相同且可以特殊召唤的怪兽
function s.spfilter(c,tc,e,tp)
	local lv=c:GetOriginalLevel()-tc:GetOriginalLevel()
	return lv>0 and lv<4
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的代价函数：发动时检查场上是否存在可送去墓地的对应怪兽卡；提示并选择1张送去墓地作为代价，并将其记录到标签对象供后续处理使用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上存在1张可作为代价送去墓地的表侧表示怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张表侧表示的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 把选择的怪兽卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- ②效果的目标函数：确认代价已支付；设置操作信息，声明将从卡组特殊召唤1只怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息：声明从卡组特殊召唤1只怪兽（卡不确定，处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：确认自己有可用怪兽区域，取回作为代价送去墓地的怪兽，提示并从卡组选择1只满足条件的怪兽，将其在自己场上表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只原本等级高1～3星且种族·属性相同的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 把选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
